module Mal.Types

struct Symbol = { name }

augment java.lang.String {

  function asSymbol = |this| -> ImmutableSymbol(this)
  function asKeyword = |this| -> "\u029E" + this

}

augment java.lang.Object {

  function isSymbol = |this| -> this oftype types.Symbol.class
  function isSymbol = |this, name| -> this: isSymbol() and this: name() == name
  function isList = |this| -> this oftype java.util.LinkedList.class
  function isFunction = |this| -> this oftype FunctionReference.class
  function isInteger = |this| -> this oftype Integer.class
  function isBoolean = |this| -> this oftype Boolean.class
  function isString = |this| -> this oftype String.class
  function isVector = |this| -> this oftype java.util.ArrayList.class
  function isMap = |this| -> this oftype java.util.Map.class
  function isIterable = |this| -> this oftype java.util.Iterable.class
  function isKeyword = |this| -> this: isString() and this: startsWith("\u029E")
  function isKeyword = |this, word| -> this: isKeyword() and this: substring(1) == word
}
