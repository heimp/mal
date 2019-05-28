module Mal.Core

import Mal.Types
import Mal.Printer

function ns = -> map[
  [ "+": asSymbol(), |a, b| -> a + b ],
  [ "-": asSymbol(), |a, b| -> a - b ],
  [ "*": asSymbol(), |a, b| -> a * b ],
  [ "/": asSymbol(), |a, b| -> a / b ],
  [ "prn": asSymbol(), |form| -> println(pr_str(form)) ],
  [ "list": asSymbol(), |x| -> x: asList() ],
  [ "list?": asSymbol(), |x| -> x: isList() ],
  [ "empty?": asSymbol(), |list| -> list: isEmpty() ],
  [ "count": asSymbol(), |list| -> list: size() ],
  [ "=": asSymbol(), |a, b| -> a == b ],
  [ "<": asSymbol(), |a, b| -> a < b ],
  [ "<=": asSymbol(), |a, b| -> a <= b ],
  [ ">": asSymbol(), |a, b| -> a > b ],
  [ ">=": asSymbol(), |a, b| -> a >= b ]
]
