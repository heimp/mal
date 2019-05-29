module Mal.Printer

import java.util.List

import Mal.Types

function pr_str = |form| -> pr_str(form, true)

function pr_str = |form, print_readably| {
  case {
    when form == null { return "nil" }
    when form: isSymbol() { return form: name() }
    when form: isInteger() { return form: toString() }
    when form: isBoolean() { return form: toString() }
    when form: isList() {
      return "(" + form: map(^pr_str): join(" ") + ")"
    }
    when form: isVector() {
      return "[" + form: map(^pr_str): join(" ") + "]"
    }
    when form: isMap() {
      return "{" + form: map(|key, value| -> pr_str(key) + " " + pr_str(value)) + "}"
    }
    when form: isFunction() { return "#<function>" }
    when form: isKeyword() { return ":" + form: substring(1) }
    when form: isString() { return "\"" + form + "\"" }
    otherwise { raise("tried to print an unrecognized type: " + form)}
  }
}
