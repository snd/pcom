P = require './pcom'

################################################################################
# U = url-pattern specific parsers

module.exports = U = {}

U.wildcard = P.tag 'wildcard', P.string('*')

U.name = P.regex '^[a-zA-Z0-9]+'

U.optional = P.tag(
  'optional'
  P.pick(1,
    P.string('(')
    P.lazy(-> U.pattern)
    P.string(')')
  )
)

U.named = P.tag(
  'named',
  P.pick(1,
    P.string(':')
    P.lazy(-> U.name)
  )
)

U.escapedChar = P.pick(1,
  P.string('\\')
  P.anyChar
)

U.static = P.tag(
  'static'
  P.concatMany1Till(
    P.firstChoice(
      P.lazy(-> U.escapedChar)
      P.anyChar
    )
    P.charset('\\*\\(\\):')
  )
)

U.token = P.lazy ->
  P.firstChoice(
    U.wildcard
    U.optional
    U.named
    U.static
  )

U.pattern = P.many1 P.lazy(-> U.token)
