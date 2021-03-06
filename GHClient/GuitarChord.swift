//
//  GuitarChord.swift
//  GuitarExample
//
//  Created by Sabintsev, Arthur on 3/11/17.
//  Copyright © 2017 Arthur Ariel Sabintsev. All rights reserved.
//

import Foundation

// MARK: - GuitarChord

/// Common Regular Expression Patterns
public enum GuitarChord: String {
  /// Pattern matches email addresses.
  case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"

  /// Pattern matches first alphanumeric character of each word.
  case firstCharacter = "(\\b\\w|(?<=_)[^_])"

  /// Pattern matches last alphanumeric character of each word.
  case lastCharacter = "(\\w\\b|[^_](?=_))"

  /// Pattern matches non-Alphanumeric characters.
  case nonAlphanumeric = "[^a-zA-Z\\d]"

  /// Pattern matches non-Alphanumeric and non-Whitespace characters.
  case nonAlphanumericSpace = "[^a-zA-Z\\d\\s]"

  /// Pattern matches @xxxx ended with whitespace
  case atUser = "@\\S*\\s"

  case url = "https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*)"

  case htmlImageTag = "<img.*>"

  case htmlSrc = "src=\".*\""

  case htmlAlt = "alt=\".*\""
}
