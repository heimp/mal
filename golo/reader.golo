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
  when peeked == "(" then read_list(reader, "(", ")")
  when peeked == "[" then read_list(reader, "[", "]")
  when peeked == "{" then read_list(reader, "{", "}")
  otherwise read_atom(reader)
} with { peeked = reader: peek() }

function read_list = |reader, opener, closer| {
  let forms = match {
    when opener == "(" then list[]
    when opener == "[" then vector[]
    otherwise map[]
  }
  reader: next() # eat the (
  var token = reader: peek()
  while token != closer {
    if token == null {
      raise("unclosed list!")
    }
    if forms: isMap() {
      let key = read_form(reader)
      if not key: isString() {
        raise("map keys can only be strings or keywords")
      }
      if reader: peek() == closer {
        raise("maps need an even number of elements")
      }
      let value = read_form(reader)
      forms: add(key, value)
    } else {
      forms: add(read_form(reader))
    }
    token = reader: peek()
  }
  reader: next() # eat the )
  return forms
}

let doubleQuotes = "\"" #"

function read_atom = |reader| {
  let atom = reader: next()
  try {
    let integer = atom: toInteger()
    return integer
  } catch (err) {}
  case {
    when atom == "true" { return true }
    when atom == "false" { return false }
    when atom == "nil" { return null }
    when atom: startsWith(":") {
      return atom: replace(":", "\u029E")
    }
    when atom: startsWith(doubleQuotes) {
      return atom: substring(1, atom: length() - 1)
    }
    otherwise { return atom: asSymbol()}
  }
}

function isBalanced = |tokens| {

  let openers = vector[]

  let isOpener = |token| -> token == "(" or token == "[" or token == "{"
  let isCloser = |token| -> token == ")" or token == "]" or token == "}"

  let matchesLast = |closer| -> match {
    when openers: isEmpty() then false
    when openers: last() == "(" then closer == ")"
    when openers: last() == "[" then closer == "]"
    when openers: last() == "{" then closer == "}"
    otherwise false
  }

  foreach token in tokens {
    case {
      when isOpener(token) { openers: add(token) }
      when isCloser(token) {
        if matchesLast(token) {
          openers: removeAt(openers: size() - 1)
        } else {
          return false
        }
      }
      otherwise {}
    }
  }
  return openers: isEmpty()
}
