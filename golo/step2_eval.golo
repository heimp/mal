#!/usr/bin/env golosh

module step2_eval

import gololang.IO
import gololang.Functions

import java.util.List

import Mal.Reader
import Mal.Printer
import Mal.Types

let repl_env = map[
  [ "+", |a, b| -> a + b ],
  [ "-", |a, b| -> a - b ],
  [ "*", |a, b| -> a * b ],
  [ "/", |a, b| -> a / b ]
]

local function READ = |x| -> read_str(x)
local function EVAL = |ast, env| {
  if not ast: isList() {
    return eval_ast(ast, env)
  }
  if ast: empty() {
    return ast
  }
  let fn, args... = eval_ast(ast, env)
  return unary(fn)(args)
}
local function PRINT = |x| -> pr_str(x)

local function rep = |x, env| -> PRINT(EVAL(READ(x), env))

local function eval_ast = |ast, env| {
  case {
    when ast: isSymbol() {
      let fn = env: get(ast: name())
      if fn == null {
        raise("symbol not found! " + ast)
      }
      return fn
    }
    when ast: isList() {
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
