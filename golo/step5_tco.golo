#!/usr/bin/env golosh

module step5_tco

import gololang.IO
import gololang.Functions

import java.util.List

import Mal.Reader
import Mal.Printer
import Mal.Environment
import Mal.Types
import Mal.Core

let repl_env = Env(null)

local function READ = |x| -> read_str(x)
local function EVAL = |initialAst, initialEnv| {
  var ast = initialAst
  var env = initialEnv
  while true {
    if ast == null {
      return null
    }
    if not ast: isList() {
      return eval_ast(ast, env)
    }
    if ast: empty() {
      return ast
    }
    let first, rest... = ast
    case {
      when first: isSymbol("def!") {
        let key, value = rest
        env: set(key, EVAL(value, env))
        return null
      }
      when first: isSymbol("let*") {
        let newEnv = Env(repl_env)
        let bindings, form = rest
        for (var i = 0, i < bindings: size(), i = i + 2) {
          let newValue = EVAL(bindings: get(i + 1), newEnv)
          newEnv: set(bindings: get(i), newValue)
        }
        env = newEnv
        ast = ast: get(2)
        continue
      }
      when first: isSymbol("do") {
        ast = eval_ast(rest: asList(): subList(0, rest: size() - 1))
        ast = rest: last()
        continue
      }
      when first: isSymbol("if") {
        let condition, thenBranch, elseBranch = rest
        let evaluated = eval_ast(condition, env)
        if evaluated != null and evaluated != false {
          ast = eval_ast(thenBranch, env)
        } else {
          ast = eval_ast(elseBranch, env)
        }
        continue
      }
      when first: isSymbol("fn*") {
        let argNames, body = rest
        return |argValues...| -> EVAL(body, Env(env, argNames, argValues: asList()))
      }
      when first: isFunction() {
        return unary(first)(rest)
      }
      otherwise {
        let fn, args... = eval_ast(ast, env)
        case {
          when fn: isFunction() { return unary(fn)(args) }
          when fn: isMalFn() {
            ast = fn: ast()
            env = Env(env, )
          }
          otherwise {code}
        }
      }
    }
  }
}
local function PRINT = |x| -> pr_str(x)

local function rep = |x, env| -> PRINT(EVAL(READ(x), env))

local function eval_ast = |ast, env| {
  case {
    when ast == null {
      return null
    }
    when ast: isSymbol() {
      let fn = env: get(ast)
      if fn == null {
        raise("symbol not found! " + ast)
      }
      return fn
    }
    when ast: isList() or ast: isVector() {
      return ast: map(|x| -> EVAL(x, env))
    }
    when ast: isMap() {
      return list[ list[ k, EVAL(v, env) ] foreach k, v in ast: entrySet() ]
    }
    otherwise {
      return ast
    }
  }
}

function main = |args| {

  ns(): each(|symbol, fn| { repl_env: set(symbol, fn) })

  let prompt = "user> "

  require(rep("(fn* (a) a)", repl_env) == "#<function>", "fn doesn't work!")
  require(rep("( (fn* (a) a) 7)", repl_env) == "7", "fn doesn't work!")
  require(rep("( (fn* (a) (+ a 1)) 10)", repl_env) == "11", "fn doesn't work!")
  require(rep("( (fn* (a b) (+ a b)) 2 3)", repl_env) == "5", "fn doesn't work!")

  while true {
    let input = readln(prompt)
    if input == null {
      println("bye!")
      break
    }
    try {
      let result = rep(input, repl_env)
      println(result)
    } catch (err) {
      println("error. " + err)
    }
  }
}
