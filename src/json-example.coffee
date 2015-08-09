P = require('./pcom')

################################################################################
# helpers

constantly = (value) ->
  -> value

pairsToObject = (pairs) ->
  object = {}
  pairs.forEach (pair) ->
    object[pair[0]] = pair[1]
  return object

removeDoubleBackslashes = (string) ->
  string
    .replace(/\\n/g, '\n')
    .replace(/\\r/g, '\r')
    .replace(/\\t/g, '\t')
    .replace(/\\"/g, '"')
    .replace(/\\'/g, '\'')
    .replace(/\\\\/g, '\\')

################################################################################
# J = url-pattern specific parsers

module.exports = J = {}

J.true = P.map(constantly(true), P.string('true'))

J.false = P.map(constantly(false), P.string('false'))

J.null = P.map(constantly(null), P.string('null'))

# J.number = P.firstChoice(P.float, P.integer)
J.number = P.integer

J.string = P.map(
  removeDoubleBackslashes
  P.pick(1,
    P.string('"')
    # match any char thats not a `"` or `\` or is a `\` followed by an arbitrary char
    # ?: is the non-capturing group
    P.regex(/^(?:[^"\\]|\\.)*/)
    P.string('"')
  )
)

# pick only J.string and J.value
J.pair = P.pick([1, 5],
  P.whitespace
  J.string
  P.whitespace
  P.string(':')
  P.whitespace
  P.lazy -> J.value
  P.whitespace
)

J.object = P.map(
  pairsToObject
  P.pick(3,
    P.whitespace
    P.string('{')
    P.whitespace
    P.separated(
      J.pair
      P.string(',')
    )
    P.whitespace
    P.string('}')
  )
)

J.array = P.pick(3,
  P.whitespace
  P.string('[')
  P.whitespace
  P.separated(
    P.pick(1,
      P.whitespace
      P.lazy -> J.value
      P.whitespace
    )
    P.string(',')
  )
  P.whitespace
  P.string(']')
)

J.value = P.firstChoice(
    J.string
    J.number
    J.true
    J.false
    J.null
    J.object
    J.array
)
