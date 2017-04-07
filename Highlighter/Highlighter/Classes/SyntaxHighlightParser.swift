//
//  SyntaxHighlightParser.swift
//  Highlighter
//
//  Created by Pi on 07/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import Foundation
import JavaScriptCore

public final class SyntaxHighlightParser {
  fileprivate static let hljsObject = "window.hljs"
  fileprivate static let jsContext:JSContext = {
    let ctx = JSContext()!
    ctx.evaluateScript("var window = {};")
    guard
      let hgPath = Bundle(for: SyntaxHighlightParser.self).path(forResource: "highlight.min", ofType: "js"),
      let hgJs = try? String.init(contentsOfFile: hgPath),
      let value = ctx.evaluateScript(hgJs),
      value.toBool()
      else { fatalError("Highlighter Initialization failed") }
    return ctx
  }()

  /**
   Returns a list of all supported languages.
   - returns: Array of Strings
   */
  public static let supportedLanguages: [String] = {
    let command = "\(hljsObject).listLanguages();"
    guard let res = jsContext.evaluateScript(command).toArray() as? [String] else { return [] }
    return res
  }()

  public static func parse(_ code: String, as languageName: String) -> String? {
//    guard SyntaxHighlightParser.supportedLanguages.contains(languageName) else { return nil }
    let fixedCode = code
      .replacingOccurrences(of: "\\",with: "\\\\")
      .replacingOccurrences(of: "\'",with: "\\\'")
      .replacingOccurrences(of: "\"", with:"\\\"")
      .replacingOccurrences(of: "\n", with:"\\n")
      .replacingOccurrences(of: "\r", with:"");
    let command = "\(hljsObject).highlight(\"\(languageName)\",\"\(fixedCode)\").value;"
    return jsContext.evaluateScript(command).toString()
  }
}































