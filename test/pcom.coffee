P = require '../src/pcom'

module.exports =

  'nothing': (test) ->
    test.deepEqual P.nothing(''),
      value: null
      rest: ''
    test.deepEqual P.nothing('foobar'),
      value: null
      rest: 'foobar'
    test.done()

  'anyChar': (test) ->
    test.deepEqual P.anyChar('foobar'),
      value: 'f'
      rest: 'oobar'
    test.deepEqual P.anyChar('foo'),
      value: 'f'
      rest: 'oo'
    test.equal P.anyChar(''), null
    test.done()

  'string': (test) ->
    parser = P.string('foo')
    test.deepEqual parser('foobar'),
      value: 'foo'
      rest: 'bar'
    test.deepEqual parser('foo'),
      value: 'foo'
      rest: ''
    test.equal parser('bar'), null
    test.equal parser(''), null
    test.done()

  'charset': (test) ->
    parser = P.charset('a-zA-Z0-9-_ %')
    test.deepEqual parser('foobar'),
      value: 'f'
      rest: 'oobar'
    test.deepEqual parser('_aa'),
      value: '_'
      rest: 'aa'
    test.deepEqual parser('a'),
      value: 'a'
      rest: ''
    test.equal parser('$foobar'), null
    test.equal parser('$'), null
    test.equal parser(''), null
    test.done()

  'concatMany1 charset': (test) ->
    parser = P.concatMany1(P.charset('a-zA-Z0-9-_ %'))
    test.deepEqual parser('foobar'),
      value: 'foobar'
      rest: ''
    test.deepEqual parser('f%_.bar'),
      value: 'f%_'
      rest: '.bar'
    test.deepEqual parser('f@bar'),
      value: 'f'
      rest: '@bar'
    test.equal parser('@bar'), null
    test.deepEqual parser('-'),
      value: '-'
      rest: ''
    test.equal parser(''), null
    test.equal parser('$aa'), null
    test.done()

  'between': (test) ->
    parser = P.between(
      P.string('(')
      P.concatMany1(P.charset('0-9'))
      P.string(')')
    )
    test.deepEqual parser('(100)'),
      value: '100'
      rest: ''
    test.deepEqual parser('(100)200'),
      value: '100'
      rest: '200'
    test.deepEqual parser('(1)()'),
      value: '1'
      rest: '()'
    test.equal parser('()'), null
    test.equal parser('foo(100)'), null
    test.equal parser('(100foo)'), null
    test.equal parser('(foo100)'), null
    test.equal parser('(foobar)'), null
    test.equal parser('foobar'), null
    test.equal parser('_aa'), null
    test.equal parser('$foobar'), null
    test.equal parser('$'), null
    test.equal parser(''), null
    test.done()

  'whitespace': (test) ->
    test.deepEqual P.whitespace(''),
      value: ''
      rest: ''
    test.deepEqual P.whitespace('x'),
      value: ''
      rest: 'x'
    test.deepEqual P.whitespace(' '),
      value: ' '
      rest: ''
    test.deepEqual P.whitespace('    }  '),
      value: '    '
      rest: '}  '
    test.done()

  'whitespace1': (test) ->
    test.equal P.whitespace1(''), null
    test.equal P.whitespace1('x'), null
    test.deepEqual P.whitespace1(' '),
      value: ' '
      rest: ''
    test.deepEqual P.whitespace1('    }  '),
      value: '    '
      rest: '}  '
    test.done()

  'integer': (test) ->
    test.deepEqual P.integer("1"),
      value: 1
      rest: ''
    test.deepEqual P.integer("-1"),
      value: -1
      rest: ''
    test.deepEqual P.integer("13939foo"),
      value: 13939
      rest: 'foo'
    test.deepEqual P.integer("-938bar"),
      value: -938
      rest: 'bar'
    test.deepEqual P.integer("-01"),
      value: 0
      rest: '1'
    test.deepEqual P.integer("0"),
      value: 0
      rest: ''
    test.deepEqual P.integer("0."),
      value: 0
      rest: '.'
    test.deepEqual P.integer("0.1"),
      value: 0
      rest: '.1'
    test.deepEqual P.integer("1.1"),
      value:1
      rest: '.1'

    test.done()
