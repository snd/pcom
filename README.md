# pcom

[![ALPHA](http://img.shields.io/badge/Stability-ALPHA-orange.svg?style=flat)]()
[![NPM Package](https://img.shields.io/npm/v/pcom.svg?style=flat)](https://www.npmjs.org/package/pcom)
[![Build Status](https://travis-ci.org/snd/pcom.svg?branch=master)](https://travis-ci.org/snd/pcom/branches)
[![Dependencies](https://david-dm.org/snd/pcom.svg)](https://david-dm.org/snd/pcom)

<!--
read what makes it special.

learn the core concepts.

grok the core concepts. look at the examples.
see how to parse json with pcom.
look at the code to see all builtin parsers and combinators.
be aware of the limitations.

very simple library to build parsers

uses the idea of parser combinators


higher order functions combine parsers.
-->

<!--
- very simple model
- embeddable (easy to copy into other libraries that needs oms
- zero dependencies

the `1` denotes that there must be at least one result.

composable


goals

simplicity

composability

embeddability

embed just the functions you need into your project


### limitations

due to its functional nature this library heavily relies on recursion instead of iteration.
when parsing very heavily nested structures the stack might pose a limit.

it isnt totally slow though
to parse a 1000 line x char json document the json example parser takes

compare that to `JSON.parse` which takes ...

development time and the length and complexity of the resulting parser
code will be significantly smaller

### TODO

find an elegant way to report the exact position where parsing failed.
longest path.
possibly error type return value instead of null.
-->

## [license: MIT](LICENSE)
