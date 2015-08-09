################################################################################
# AMD, CommonJS and browser support

((root, factory) ->
  # AMD
  if ('function' is typeof define) and define.amd?
    define([], factory)
  # CommonJS
  else if exports?
    module.exports = factory()
  # no module system
  else
    root.parserCombinators = factory()
)(this, ->

################################################################################
# core

  P = {}

  P.Result = (value, rest) ->
    this.value = value
    this.rest = rest
    return

  P.nothing = (input) ->
    return new P.Result null, input

  P.anyChar = (input) ->
    if input is ''
      return
    return new P.Result input.charAt(0), input.slice(1)

  P.string = (string) ->
    length = string.length
    if length is 0
      throw new Error '`string` must not be blank'
    else if length is 1
      (input) ->
        # console.log 'P.string',
        #   string: string
        #   input: input
        #   isMatch: input.charAt(0) is string
        if input.charAt(0) is string
          return new P.Result string, input.slice(1)
    else
      (input) ->
        if input.slice(0, length) is string
          return new P.Result string, input.slice(length)

  P.regex = (arg) ->
    regex = if 'string' is typeof arg then new RegExp '^' + arg else arg
    (input) ->
      # console.log 'P.regex',
      #   string: string
      #   input:
      matches = regex.exec input
      unless matches?
        return
      # console.log regex.toString()
      # console.log matches
      result = matches[0]
      return new P.Result result, input.slice(result.length)

  # consumes any whitespace
  P.whitespace = P.regex('\\s*')
  P.whitespace1 = P.regex('\\s+')

  P.charset = (charset) ->
    regex = new RegExp '^['  + charset + ']$'
    (input) ->
      char = input.charAt(0)
      unless regex.test char
        return
      return new P.Result char, input.slice(1)

  # returns result of the first parser that consumes anything
  P.firstChoice = (parsers...) ->
    (input) ->
      i = -1
      length = parsers.length
      while ++i < length
        parser = parsers[i]
        unless 'function' is typeof parser
          throw new Error "parser passed at index `#{i}` into `firstChoice` is not of type `function` but of type `#{typeof parser}`"
        result = parser input
        # console.log 'firstChoice',
        #   input: input
        #   i: i
        #   result: result
        if result?
          return result
      return

  # returns result of the parser that consumes the most (leaves the shortest rest)
  # or the parser that comes first when two parsers are tied
  P.longestChoice = (parsers...) ->
    (input) ->
      i = -1
      length = parsers.length
      bestResult = null
      while ++i < length
        parser = parsers[i]
        unless 'function' is typeof parser
          throw new Error "parser passed at index `#{i}` into `longestChoice` is not of type `function` but of type `#{typeof parser}`"
        result = parser input
        # left a longer rest?
        if result? and ((not bestResult?) or bestResult.rest.length > result.rest.length)
          bestResult = result
      return bestResult

  P.baseMany = (parser, end, stringResult, atLeastOneResultRequired, input) ->
    rest = input
    results = if stringResult then '' else []
    while true
      if end?
        endResult = end rest
        if endResult?
          break
      parserResult = parser rest
      unless parserResult?
        break
      if stringResult
        results += parserResult.value
      else
        results.push parserResult.value
      rest = parserResult.rest

    if atLeastOneResultRequired and results.length is 0
      return

    return new P.Result results, rest

  P.many = (parser) ->
    (input) ->
      P.baseMany parser, null, false, false, input

  P.many1 = (parser) ->
    (input) ->
      P.baseMany parser, null, false, true, input

  P.concatMany1 = (parser) ->
    (input) ->
      P.baseMany parser, null, true, true, input

  P.concatMany1Till = (parser, end) ->
    (input) ->
      P.baseMany parser, end, true, true, input

  P.lazy = (fn) ->
    cached = null
    (input) ->
      unless cached?
        cached = fn()
      return cached input

  P.Tagged = (tag, value) ->
    this.tag = tag
    this.value = value
    return

  P.map = (fn, parser) ->
    (input) ->
      result = parser input
      unless result
        return
      return new P.Result fn(result.value), result.rest

  P.tag = (tag, parser) ->
    (input) ->
      result = parser input
      unless result
        return
      tagged = new P.Tagged tag, result.value
      return new P.Result tagged, result.rest

  P.maybe = (parser, returnValue = null) ->
    (input) ->
      result = parser input
      if result
        result
      else
        new P.Result returnValue, input

  P.sequence = (parsers...) ->
    (input) ->
      i = -1
      length = parsers.length
      values = []
      rest = input
      # console.log parsers
      while ++i < length
        # console.log 'sequence',
        #   i: i
        #   parser: parsers[i]
        #   rest: rest
        parser = parsers[i]
        unless 'function' is typeof parser
          throw new Error "parser passed at index `#{i}` into `sequence` is not of type `function` but of type `#{typeof parser}`"
        result = parser rest
        # console.log 'sequence',
        #   input: input
        #   i: i
        #   result: result
        unless result?
          return
        values.push result.value
        rest = result.rest
      # console.log 'values', values
      return new P.Result values, rest

  P.pick = (indexes, parsers...) ->
    (input) ->
      # console.log 'pick before P.sequence',
      #   input: input
      result = P.sequence(parsers...)(input)
      # console.log 'pick after P.sequence',
      #   result: result
      unless result?
        return
      array = result.value
      unless Array.isArray indexes
        result.value = array[indexes]
      else
        result.value = []
        indexes.forEach (i) ->
          result.value.push array[i]
      return result

  # must not end on a separator
  P.separated1 = (parser, separator) ->
    P.map(
      (values) ->
        # flatten results
        values[1].unshift values[0]
        return values[1]
      P.sequence(
        parser
        P.many(
          P.pick(1, separator, parser)
        )
      )
    )

  P.separated = (parser, separator) ->
    P.maybe(P.separated1(parser,separator), [])

  P.between = (open, parser, close) ->
    P.pick(1, open, parser, close)
    # (input) ->
    #   openResult = open input
    #   unless openResult?
    #     return
    #   parserResult = parser openResult.rest
    #   unless parserResult?
    #     return
    #   closeResult = close parserResult.rest
    #   unless closeResult?
    #     return
    #   return new P.Result(parserResult.value, closeResult.rest)

  # pick tagged ?

  # P.map to map something onto the results

  # P.late instead of lazy

  P.integer = P.map(
    (x) -> parseInt(x, 10)
    P.regex('-?(0|[1-9][0-9]*)')
  )

  P.float = P.map(
    parseFloat
    P.regex('-?[1-9][0-9]*\.[0-9]+')
  )

################################################################################
# nice to have

  P.commaSeparated = (parser) ->
    P.separated(
      P.string(',')
      parser
    )

  P.betweenParentheses = (parser) ->
    P.between(
      P.string('(')
      parser
      P.string(')')
    )

################################################################################
# return from factory

  return P
)
