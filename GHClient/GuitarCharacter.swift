//
//  GuitarCharacter.swift
//  GuitarExample
//
//  Created by Sabintsev, Arthur on 3/9/17.
//  Copyright © 2017 Arthur Ariel Sabintsev. All rights reserved.
//

import Foundation

/// Character Operations
public extension String {

    /// Returns the first character of the string.
    ///
    ///     let string = "Hello World"
    ///     print(string.first())
    ///     // Prints "H"
    ///
    /// - Returns: The first character of the string.
    @discardableResult
    func first() -> String {
        return String(describing: self[startIndex])
    }

  /// Returns the first n characters of the string.
  ///
  ///     let string = "Hello World"
  ///     print(string.first(2))
  ///     // Prints "He"
  ///
  /// - Returns: The first character of the string.
  @discardableResult
  func first(_ n: UInt) -> String {
    let idx = index(startIndex, offsetBy: String.IndexDistance(n), limitedBy: endIndex) ?? endIndex
    return substring(with: startIndex ..< idx)
  }

    /// Returns the last character of the string.
    ///
    ///     let string = "Hello World"
    ///     print(string.last())
    ///     // Prints "d"
    ///
    /// - Returns: The last character of the string.
    @discardableResult
    func last() -> String {
        return reversed().first()
    }

  /// Returns the last n characters of the string.
  ///
  ///     let string = "Hello World"
  ///     print(string.last())
  ///     // Prints "ld"
  ///
  /// - Returns: The last character of the string.
  @discardableResult
  func last(_ n: UInt) -> String {
    return reversed().first(n).reversed()
  }

    /// Returns the character count of the string.
    ///
    ///     let string = "Hello World"
    ///     print(string.length())
    ///     // Prints 11
    ///
    /// - Returns: The character count of the string.
    func length() -> Int {
        return characters.count
    }

    /// Retuns the reversed version of the string.
    ///
    ///     let string = "Hello World"
    ///     print(string.reversed())
    ///     // Prints "dlroW olleH"
    ///
    /// - Returns: The reversed copy of the string.
    @discardableResult
    func reversed() -> String {
        return String(characters.reversed())
    }
}





















