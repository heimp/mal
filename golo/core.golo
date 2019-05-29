module Mal.Core

import gololang.Functions

import Mal.Types
import Mal.Printer

function ns = -> map[
  [ "+", ^add ],
  [ "-", ^sub ],
  [ "*", ^mul ],
  [ "/", ^div ],
  [ "prn", pipe(^pr_str, ^println) ],
  [ "list", |rest...| -> list[ x  foreach x in rest ] ],
  [ "list?", |form| -> form: isList() ],
  [ "empty?", ^isEmpty ],
  [ "count", |list| -> list: size() ],
  [ "=", ^eq ],
  [ "<", swap(^lt) ],
  [ "<=", swap(^le) ],
  [ ">", swap(^gt) ],
  [ ">=", swap(^ge) ]
]: map(|id, fn| -> mapEntry(id: asSymbol(), fn))
