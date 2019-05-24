#!/usr/bin/env golosh

module step0_repl

import gololang.IO

local function READ = |x| -> x
local function EVAL = |x| -> x
local function PRINT = |x| -> x

# local function rep = |x| -> PRINT(EVAL(READ(x)))
let rep = ^READ: andThen(^EVAL): andThen(^PRINT)

function main = |args| {

  let prompt = "user> "

  while true {
    let input = readln(prompt)
    if input == null {
      println("bye!")
      break
    }
    let result = rep(input)
    println(result)
  }
}
