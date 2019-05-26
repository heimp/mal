module Mal.Environment

struct Env = { outer, data }

function Env = |outer| -> Env(outer, map[])

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
