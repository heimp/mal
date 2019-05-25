#!/usr/bin/env golosh

module step2_eval

import gololang.IO

import java.util.List

import Mal.Reader
import Mal.Printer

let repl_env = map[
  [ "+", |a, b| -> a + b ],
  [ "-", |a, b| -> a - b ],
  [ "*", |a, b| -> a * b ],
  [ "/", |a, b| -> a / b ]
]

local function READ = |x| -> read_str(x)
local function EVAL = |ast, env| {
  case {
    when ast oftype List.class {
      if ast: empty() {
        return ast
      } else {
        let newList = eval_ast(ast, env)
        let fn = newList: head()
        let args = newList: tail()
        let a = newList: get(1)
        let b = newList: get(2)
        # return fn: spread(args)
        return fn(a, b)
      }
    }
    otherwise { return eval_ast(ast, env) }
  }
}
local function PRINT = |x| -> pr_str(x)

local function rep = |x, env| -> PRINT(EVAL(READ(x), env))
# let rep = ^READ: andThen(^EVAL: bintAt(1, repl_env)): andThen(^PRINT)

function eval_ast = |ast, env| {
  case {
    when ast oftype Mal.Types.types.Symbol.class {
      let fn = env: get(ast: name())
      if fn == null {
        raise("symbol not found! " + ast)
      }
      return fn
    }
    when ast oftype List.class {
      return ast: map(|x| -> EVAL(x, env))
    }
    otherwise { return ast }
  }
}

function main = |args| {

  require(rep("(+ 2 3)", repl_env) == "5", "Bad math! did not = 5")
  require(rep("(+ 2 (* 3 4))", repl_env) == "14", "Bad math! did not = 14")

  let prompt = "user> "

  while true {
    let input = readln(prompt)
    if input == null {
      println("bye!")
      break
    }
    let result = rep(input, repl_env)
    println(result)
  }
}
