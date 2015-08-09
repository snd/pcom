F = require '../src/function-signature-example'

parse = F.signature

module.exports =

  'fixtures': (test) ->
    test.equal parse(''), null
    test.equal parse('#'), null
    test.equal parse(' foo'), null

    test.deepEqual parse('foo'),
      value: ['foo', []]
      rest: ''
    test.deepEqual parse('foo('),
      value: ['foo', []]
      rest: '('
    test.deepEqual parse('foo)'),
      value: ['foo', []]
      rest: ')'
    test.deepEqual parse('foo()'),
      value: ['foo', []]
      rest: ''
    test.deepEqual parse('fooBarBaz42()'),
      value: ['fooBarBaz42', []]
      rest: ''
    test.deepEqual parse('fooBar Baz42()'),
      value: ['fooBar', []]
      rest: ' Baz42()'
    test.deepEqual parse('fooBarBaz42 ()'),
      value: ['fooBarBaz42', []]
      rest: ' ()'
    test.deepEqual parse('fooBarBaz42( )'),
      value: ['fooBarBaz42', []]
      rest: ''
    test.deepEqual parse('fooBarBaz42(    )'),
      value: ['fooBarBaz42', []]
      rest: ''

    test.deepEqual parse('fooBarBaz42(1)'),
      value: ['fooBarBaz42', [1]]
      rest: ''
    test.deepEqual parse('fooBarBaz42( 1 )'),
      value: ['fooBarBaz42', [1]]
      rest: ''
    test.deepEqual parse('fooBarBaz42( 1, )'),
      value: ['fooBarBaz42', []]
      rest: '( 1, )'
    test.deepEqual parse('fooBarBaz42( 1,  2, 3)'),
      value: ['fooBarBaz42', [1, 2, 3]]
      rest: ''
    test.deepEqual parse("fooBarBaz42( 1,  'two', 3)"),
      value: ['fooBarBaz42', [1, 'two', 3]]
      rest: ''
    test.deepEqual parse("fooBarBaz42('one')"),
      value: ['fooBarBaz42', ['one']]
      rest: ''

    test.deepEqual parse("fooBarBaz42(one)"),
      value: ['fooBarBaz42', []]
      rest: '(one)'

    test.done()
