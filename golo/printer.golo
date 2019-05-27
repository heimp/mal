module Mal.Printer

import java.util.List

import Mal.Types

function pr_str = |form| {
  case {
    when form == null { return "nil" }
    when form: isSymbol() { return form: name() }
    when form: isInteger() { return form: toString() }
    when form: isBoolean() { return form: toString() }
    when form: isList() {
      return "(" + form: map(^pr_str): join(" ") + ")"
    }
    when form: isFunction() { return "#<function>" }
    otherwise { raise("tried to print an unrecognized type: " + form)}
  }
}
