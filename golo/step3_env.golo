#!/usr/bin/env golosh

module step3_env

import gololang.IO
import gololang.Functions

import java.util.List

import Mal.Reader
import Mal.Printer
import Mal.Environment
import Mal.Types

let repl_env = Env(null)

local function READ = |x| -> read_str(x)
local function EVAL = |ast, env| {
  if not ast: isList() {
    return eval_ast(ast, env)
  }
  if ast: empty() {
    return ast
  }
  let first, rest... = ast
  case {
    when first == ImmutableSymbol("def!") {
      let key, value = rest
      env: set(key, value)
    }
    when first == ImmutableSymbol("let*") {
      let newEnv = Env(repl_env)
      let bindings, form = rest
      for (var i = 0, i < bindings: size(), i = i + 2) {
        let newValue = EVAL(bindings: get(i + 1), newEnv)
        newEnv: set(bindings: get(i), newValue)
      }
      return EVAL(form, newEnv)
    }
    otherwise {
      let fn, args... = eval_ast(ast, env)
      return unary(fn)(args)
    }
  }
}
local function PRINT = |x| -> pr_str(x)

local function rep = |x, env| -> PRINT(EVAL(READ(x), env))

local function eval_ast = |ast, env| {
  case {
    when ast: isSymbol() {
      let fn = env: get(ast)
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

  repl_env: set("+": asSymbol(), |a, b| -> a + b )
  repl_env: set("-": asSymbol(), |a, b| -> a - b )
  repl_env: set("*": asSymbol(), |a, b| -> a * b )
  repl_env: set("/": asSymbol(), |a, b| -> a / b )

  require(rep("(def! a 6)", repl_env) == "6", "def doesn't work!")
  require(rep("a", repl_env) == "6", "def doesn't work!")
  require(rep("(def! b (+ a 2))", repl_env) == "8", "def doesn't work!")
  require(rep("(+ a b)", repl_env) == "14", "def doesn't work!")
  require(rep("(let* (c 2) c)", repl_env) == "2", "let doesn't work!")

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
