#!/usr/bin/env golosh

module step4_if_fn_do

import gololang.IO

import java.util.List

import Mal.Reader
import Mal.Printer
import Mal.Environment
import Mal.Types

let repl_env = Env(null)

local function READ = |x| -> read_str(x)
local function EVAL = |ast, env| {
  if not (ast oftype List.class) {
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
    when first == ImmutableSymbol("do") {
      return eval_ast(rest, env)
    }
    when first == ImmutableSymbol("if") {
      let condition, thenBranch, elseBranch = rest
      let evaluated = eval_ast(condition, env)
      if evaluated != null and evaluated != false {
        return eval_ast(thenBranch, env)
      } else {
        return eval_ast(elseBranch, env)
      }
    }
    when first == ImmutableSymbol("fn*") {
      println("making a fn outta " + rest)
      let argNames, body... = rest
      return |argValues| -> EVAL(body, Env(env, argNames, argValues))
    }
    when first oftype FunctionReference.class {
      return first(rest)
    }
    when first oftype Mal.Types.types.Symbol.class {
      println("otherwise! " + first + " and the rest is " + rest)
      let fn, a, b = eval_ast(ast, env)
      println("function name is " + fn + "and arg a is " + a + " arg b: " + b)
      return fn(a, b)
    }
    otherwise {
      raise("couldn't recognize this type to EVAL! " + first)
    }
  }
}
local function PRINT = |x| -> pr_str(x)

local function rep = |x, env| -> PRINT(EVAL(READ(x), env))

function eval_ast = |ast, env| {
  case {
    when ast oftype Mal.Types.types.Symbol.class {
      let fn = env: get(ast)
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

  repl_env: set(ImmutableSymbol("+"), |a, b| -> a + b )
  repl_env: set(ImmutableSymbol("-"), |a, b| -> a - b )
  repl_env: set(ImmutableSymbol("*"), |a, b| -> a * b )
  repl_env: set(ImmutableSymbol("/"), |a, b| -> a / b )

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
