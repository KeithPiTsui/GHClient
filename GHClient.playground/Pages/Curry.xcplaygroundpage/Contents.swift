//: [Previous](@previous)

import Foundation

public func curry<A, B>(_ function: @escaping (A) -> B) -> (A) -> B {
  return { (a: A) -> B in function(a) }
}

public func curry<A, B, C>(_ function: @escaping (A, B) -> C) -> (A) -> (B) -> C {
  return { (a: A) -> (B) -> C in { (b: B) -> C in function(a, b) } }
}

public func curry<A, B, C, D>(_ function: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
  return { (a: A) -> (B) -> (C) -> D in { (b: B) -> (C) -> D in { (c: C) -> D in function(a, b, c) } } }
}

func add(a: Int, b: Int, c: Int) -> Int {
  return a + b + c
}

let addFunc = curry(add)

protocol A {

  associatedtype T = Array<Any>

  func add(a: T)
}