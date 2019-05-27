module Mal.Reader

import java.util.regex.Pattern
import java.util.regex.Compile

import gololang.Decorators

import Mal.Types

struct Reader = { tokens, position }

augment Reader {

  function next = |this| {
    try {
      let token = this: tokens(): get(this: position())
      this: position(this: position() + 1)
      return token
    } catch (err) {
      println("error!")
      return null
    }
  }

  function peek = |this| {
    try {
      return this: tokens(): get(this: position())
    } catch (err) {
      println("error!")
      return null
    }
  }
}

function Reader = |tokens| -> Reader(tokens, 0)

function read_str = |input| {
  require(input oftype String.class, "input must be a String")
  let tokens = tokenize(input)
  let reader = Reader(tokens)
  return read_form(reader)
}

function tokenize = |input| {
  require(input oftype String.class, "input must be a String")
  let pattern = compile("""[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"?|;.*|[^\s\[\]{}('"`,;)]*)""") # |
  let matcher = pattern: matcher(input)
  let groups = vector[]
  while matcher: find() {
    let group = matcher: group(1)
    if not group: startsWith(";") and not group: isEmpty() {
      groups: add(group)
    }
  }

  if not isBalanced(groups) {
    raise("unbalanced brackets")
  }

  return groups
}

function read_form = |reader| -> match {
  when reader: peek() == "(" then read_list(reader)
  otherwise read_atom(reader)
}

function read_list = |reader| {
  reader: next() # eat the (
  let forms = list[]
  var token = reader: peek()
  while token != ")" {
    if token == null {
      raise("unclosed list!")
    }
    forms: add(read_form(reader))
    token = reader: peek()
  }
  reader: next() # eat the )
  return forms
}

function read_atom = |reader| {
  let atom = reader: next()
  try {
    let integer = atom: toInteger()
    return integer
  } catch (err) {
    return atom: asSymbol()
  }
}

function isBalanced = |tokens| {
  var parens = 0
  var braces = 0
  var brackets = 0
  foreach token in tokens {
    case {
      when token: isSymbol("(") { parens = parens + 1 }
      when token: isSymbol("{") { braces = braces + 1 }
      when token: isSymbol("[") { brackets = brackets + 1 }
      when token: isSymbol(")") {
        parens = parens - 1
        if parens < 0 {
          return false
        }
      }
      when token: isSymbol("}") {
        braces = braces - 1
        if braces < 0 {
          return false
        }
      }
      when token: isSymbol("]") {
        brackets = brackets - 1
        if brackets < 0 {
          return false
        }
      }
      otherwise {}
    }
  }
  return parens == 0 and braces == 0 and brackets == 0
}
