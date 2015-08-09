fs = require 'fs'
path = require 'path'

J = require '../src/json-example'

module.exports =

  'string': (test) ->
    test.deepEqual J.value("\"i'm a string\""),
      value: "i'm a string"
      rest: ''
    test.deepEqual J.value("\"i'm a string\"and i'm no longer a string"),
      value: "i'm a string"
      rest: "and i'm no longer a string"
    test.deepEqual J.value('""'),
      value: ''
      rest: ''
    test.deepEqual J.value('"\\"\\""'),
      value: '\\"\\"'
      rest: ''
    test.deepEqual J.value('"\\"\n"'),
      value: '\\"\n'
      rest: ''
    test.equal J.value(""), null
    test.equal J.value("\n"), null
    test.done()

  'true': (test) ->
    test.deepEqual J.value("true"),
      value: true
      rest: ''
    test.deepEqual J.value("trueee"),
      value: true
      rest: 'ee'
    test.equal J.value("folse"), null
    test.done()

  'false': (test) ->
    test.deepEqual J.value("false"),
      value: false
      rest: ''
    test.deepEqual J.value("falseee"),
      value: false
      rest: 'ee'
    test.equal J.value("folse"), null
    test.done()

  'null': (test) ->
    test.deepEqual J.value("null"),
      value: null
      rest: ''
    test.deepEqual J.value("nullll"),
      value: null
      rest: 'll'
    test.equal J.value("noll"), null
    test.done()

  'empty object': (test) ->
    test.deepEqual J.value("{}"),
      value: {}
      rest: ''
    test.deepEqual J.value("  {    }  "),
      value: {}
      rest: '  '
    test.deepEqual J.value("{}x"),
      value: {}
      rest: 'x'
    test.done()

  'object with single property': (test) ->
    test.equal J.value('{foo}'), null
    test.equal J.value('{"foo"}'), null
    test.equal J.value('{"foo":}'), null
    test.equal J.value('{"foo":  }'), null
    test.equal J.value('{"foo":  }'), null
    test.equal J.value('{"foo":  "}'), null
    test.equal J.value('{"foo":  "bar}'), null

    test.deepEqual J.value('{"foo":  "bar"}'),
      value:
        foo: 'bar'
      rest: ''
    test.done()

  'empty array': (test) ->
    test.deepEqual J.value("[]"),
      value: []
      rest: ''
    test.deepEqual J.value(" [    ] "),
      value: []
      rest: ' '
    test.deepEqual J.value("[]x"),
      value: []
      rest: 'x'
    test.done()

  'fixtures': (test) ->
    values = [
      {foo: 'bar'}
      {foo_bar: 1}
      {'foo%': true}
      {'290foo%': null}
      {_: false}
      {foo: {bar: 'baz'}}
      {foo: []}
      {foo: {bar: ['baz']}}
      []
      [[[]]]
    ]

    test.expect values.length * 2

    values.forEach (value) ->
      string = JSON.stringify(value)
      test.deepEqual J.value(string),
        value: value
        rest: ''
      test.deepEqual J.value(string + 'foo'),
        value: value
        rest: 'foo'
    test.done()
