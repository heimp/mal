module Mal.Printer

import java.util.List

import Mal.Types

function pr_str = |form| {
  case {
    when form oftype FunctionReference.class { return "#<function>" }
    when form == null { return "nil" }
    when form oftype Boolean.class { return form: toString() }
    when form oftype Mal.Types.types.Symbol.class { return form: name() }
    when form oftype Integer.class { return form: toString() }
    when form oftype List.class {
      return "(" + form: map(^pr_str): join(" ") + ")"
    }
    otherwise { raise("tried to print an unrecognized type: " + form)}
  }
}
