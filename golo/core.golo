module Mal.Core

import gololang.Functions

import Mal.Types
import Mal.Printer

local function stringify = |arr, readable| -> arr: asList(): map(|el| -> pr_str(el, readable)): join(" ")

function ns = -> map[
  [ "+", ^add ],
  [ "-", ^sub ],
  [ "*", ^mul ],
  [ "/", ^div ],
  [ "list", |rest...| -> list[ x  foreach x in rest ] ],
  [ "list?", |form| -> form: isList() ],
  [ "empty?", ^isEmpty ],
  [ "count", |list| -> list: size() ],
  [ "=", ^eq ],
  [ "<", swap(^lt) ],
  [ "<=", swap(^le) ],
  [ ">", swap(^gt) ],
  [ ">=", swap(^ge) ],
  [ "pr-str", |rest...| -> stringify(rest, true) ],
  [ "str", |rest...| -> stringify(rest, false) ],
  [ "prn", |rest...| -> println(stringify(rest, true)) ],
  [ "println", |rest...| -> println(stringify(rest, false)) ]
]: map(|id, fn| -> mapEntry(id: asSymbol(), fn))
