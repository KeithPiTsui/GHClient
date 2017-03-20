//
//  Highlightr.swift
//  Pods
//
//  Created by Illanes, J.P. on 4/10/16.
//
//

import Foundation
import JavaScriptCore

/// Utility class for generating a highlighted NSAttributedString from a String.
open class Highlightr {

  fileprivate static let bundle = Bundle(for: Highlightr.self)

  /**
   Returns a list of all the available themes.
   - returns: Array of Strings
   */
  open static let availableThemes: [String] = {
    let paths = Highlightr.bundle.paths(forResourcesOfType: "css", inDirectory: nil) as [NSString]
    return paths.map{$0.lastPathComponent.replacingOccurrences(of: ".min.css", with: "")}
  }()

  /// Returns the current Theme.
  open var theme : Theme! { didSet { themeChanged?(theme) } }

  /// This block will be called every time the theme changes.
  open var themeChanged : ((Theme) -> Void)?

  fileprivate let jsContext = JSContext()!
  fileprivate let hljs = "window.hljs"
  fileprivate let htmlStart = "<"
  fileprivate let spanStart = "span class=\""
  fileprivate let spanStartClose = "\">"
  fileprivate let spanEnd = "/span>"
  fileprivate let htmlEscape = try! NSRegularExpression(pattern: "&#?[a-zA-Z0-9]+?;", options: .caseInsensitive)

  /**
   Default init method.
   - returns: Highlightr instance.
   */
  public init() {
    self.jsContext.evaluateScript("var window = {};")
    guard
      let hgPath = Highlightr.bundle.path(forResource: "highlight.min", ofType: "js"),
      let hgJs = try? String.init(contentsOfFile: hgPath),
      let value = jsContext.evaluateScript(hgJs),
      value.toBool(),
      self.setTheme(to: "pojoaque")
      else {
        fatalError("Highlighter Initialization failed")
    }
  }

  /**
   Set the theme to use for highlighting.
   - parameter to: Theme name
   - returns: true if it was possible to set the given theme, false otherwise
   */
  @discardableResult
  open func setTheme(to name: String) -> Bool {
    guard
      let defTheme = Highlightr.bundle.path(forResource: name+".min", ofType: "css"),
      let themeString = try? String.init(contentsOfFile: defTheme)
      else { return false}
    self.theme =  Theme(themeString: themeString)
    return true
  }

  /**
   Returns a list of all supported languages.
   - returns: Array of Strings
   */
  open var supportedLanguages: [String] {
    let command =  String.init(format: "%@.listLanguages();", hljs)
    guard let res = jsContext.evaluateScript(command).toArray() as? [String] else { return [] }
    return res
  }

  /**
   Takes a String and returns a NSAttributedString with the given language highlighted.
   - parameter code:           Code to highlight.
   - parameter languageName:   Language name or alias. Set to `nil` to use auto detection.
   - parameter fastRender:     Defaults to true - When *true* will use the custom made html parser rather than Apple's solution.
   - returns: NSAttributedString with the detected code highlighted.
   */
  open func highlight(_ code: String, as languageName: String? = nil, fastRender: Bool = true)
    -> NSAttributedString? {

      let fixedCode = code
        .replacingOccurrences(of: "\\",with: "\\\\")
        .replacingOccurrences(of: "\'",with: "\\\'")
        .replacingOccurrences(of: "\"", with:"\\\"")
        .replacingOccurrences(of: "\n", with:"\\n")
        .replacingOccurrences(of: "\r", with:"");

      let command: String
        = languageName != nil
          ? String.init(format: "%@.highlight(\"%@\",\"%@\").value;", hljs, languageName!, fixedCode)
          : String.init(format: "%@.highlightAuto(\"%@\").value;", hljs, fixedCode)

      guard let highlightedHtmlString = jsContext.evaluateScript(command).toString() else { return nil }

      return fastRender
        ? processHTMLString(highlightedHtmlString)
        : {
          let str = "<style>"
            + theme.lightTheme
            + "</style><pre><code class=\"hljs\">"
            + highlightedHtmlString
            + "</code></pre>"
          let opt: [String : Any] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: String.Encoding.utf8]
          let data = str.data(using: String.Encoding.utf8)!
          return try? NSMutableAttributedString(data:data,options:opt as [String:AnyObject],documentAttributes:nil)
        }()
  }


  fileprivate func processHTMLString(_ string: String) -> NSAttributedString? {
    let scanner = Scanner(string: string)
    scanner.charactersToBeSkipped = nil
    var scannedString: NSString?
    let resultString = NSMutableAttributedString(string: "")
    var propStack = ["hljs"]

    while !scanner.isAtEnd {
      var ended = false
      if scanner.scanUpTo(htmlStart, into: &scannedString) {
        if scanner.isAtEnd { ended = true }
      }

      if scannedString != nil && scannedString!.length > 0 {
        let attrScannedString = theme.applyStyleToString(scannedString! as String, styleList: propStack)
        resultString.append(attrScannedString)
        if ended { continue }
      }

      scanner.scanLocation += 1

      let string = scanner.string as NSString
      let nextChar = string.substring(with: NSMakeRange(scanner.scanLocation, 1))

      if(nextChar == "s") {
        scanner.scanLocation += (spanStart as NSString).length
        scanner.scanUpTo(spanStartClose, into:&scannedString)
        scanner.scanLocation += (spanStartClose as NSString).length
        propStack.append(scannedString! as String)
      } else if(nextChar == "/") {
        scanner.scanLocation += (spanEnd as NSString).length
        propStack.removeLast()
      } else {
        let attrScannedString = theme.applyStyleToString("<", styleList: propStack)
        resultString.append(attrScannedString)
        scanner.scanLocation += 1
      }

      scannedString = nil
    }

    let results = htmlEscape.matches(in: resultString.string,
                                     options: [.reportCompletion],
                                     range: NSMakeRange(0, resultString.length))
    var locOffset = 0
    for result in results {
      let fixedRange = NSMakeRange(result.range.location-locOffset, result.range.length)
      let entity = (resultString.string as NSString).substring(with: fixedRange)
      if let decodedEntity = HTMLUtils.decode(entity) {
        resultString.replaceCharacters(in: fixedRange, with: String(decodedEntity))
        locOffset += result.range.length-1;
      }
    }
    
    return resultString
  }
}
