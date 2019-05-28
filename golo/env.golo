module Mal.Environment

struct Env = { outer, data }

function Env = |outer| -> Env(outer, map[])

function Env = |outer, binds, exprs| {
  # require(binds: isIterable(), "binds is not a list")
  # require(exprs: isIterable(), "exprs is not a list")
  let data = map[]
  foreach i in [0..binds: size()] {
    let a = binds: get(i)
    let b = exprs: get(i)
    data: put(a, b)
  }
  return Env(outer, data)
}

augment Env {

  function set = |this, key, value| { this: data(): put(key, value) }

  function find = |this, key| {
    if this: data(): containsKey(key) {
      return this
    } else {
      return this: outer()?: find(key)
    }
  }

  function get = |this, key| {
    let env = this: find(key)
    if env != null {
      return env: data(): get(key)
    } else {
      raise("not found in env: " + key)
    }
  }
}
