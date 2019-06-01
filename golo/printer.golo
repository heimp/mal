module Mal.Printer

import java.util.List

import Mal.Types

function pr_str = |form| -> pr_str(form, true)

function pr_str = |form, print_readably| {
  case {
    when form == null { return "nil" }
    when form: isSymbol() { return form: name() }
    when form: isInteger() or form: isBoolean() {
      return form: toString()
    }
    when form: isList() or form: isVector() {
      let opener, closer = match {
        when form: isList() then ["(", ")"]
        otherwise ["[", "]"]
      }
      return opener + form: map(|el| -> pr_str(el, print_readably)): join(" ") + closer
    }
    when form: isMap() {
      let p = ^pr_str\2: bindAt(1, print_readably)
      return "{" + vector[ p(k) + " " + p(v) foreach k, v in form: entrySet() ]: join(" ") + "}"
    }
    when form: isFunction() { return "#<function>" }
    when form: isKeyword() { return ":" + form: substring(1) }
    when form: isString() {
      if print_readably {
        return "\"" + form: replace("\"", "\\\""): replace("\n", "\\n"): replace("\\", "\\\\")  + "\""
      } else {
        return "\"" + form + "\""
      }
    }
    otherwise { raise("tried to print an unrecognized type: " + form)}
  }
}
