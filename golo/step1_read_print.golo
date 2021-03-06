#!/usr/bin/env golosh

module step1_read_print

import gololang.IO

import Mal.Reader
import Mal.Printer

local function READ = |x| -> read_str(x)
local function EVAL = |x| -> x
local function PRINT = |x| -> pr_str(x)

let rep = ^READ: andThen(^EVAL): andThen(^PRINT)

function main = |args| {

  let prompt = "user> "

  while true {
    let input = readln(prompt)
    if input == null {
      println("bye!")
      break
    }
    try {
      let result = rep(input)
      println(result)
    } catch (err) {
      println("error. try again.")
    }
  }
}
