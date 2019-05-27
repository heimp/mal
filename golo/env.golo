module Mal.Environment

struct Env = { outer, data }

function Env = |outer| -> Env(outer, map[])

function Env = |outer, binds, exprs| {
  let data = map[]
  foreach i in [0..binds: size()] {
    let a = binds: get(1)
    let b = exprs: get(1)
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
