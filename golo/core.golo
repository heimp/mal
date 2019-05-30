module Mal.Core

import gololang.Functions

import Mal.Types
import Mal.Printer

let readable = ^pr_str\1
let unreadable = ^pr_str\2: bindAt(1, false)

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
  [ "pr-str", |rest...| -> rest: asList(): map(readable): join(" ") ],
  [ "str", |rest...| -> rest: asList(): map(unreadable): join(" ") ],
  [ "prn", |rest...| -> println(rest: asList(): map(readable): join(" ")) ],
  [ "println", |rest...| -> println(rest: asList(): map(unreadable): join(" ")) ]
]: map(|id, fn| -> mapEntry(id: asSymbol(), fn))
