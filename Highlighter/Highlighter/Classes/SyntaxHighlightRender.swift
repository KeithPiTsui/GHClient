//
//  SyntaxHighlightRender.swift
//  Highlighter
//
//  Created by Pi on 07/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import Foundation

public final class SyntaxHighlightRender {
  /**
   Returns a list of all the available themes.
   - returns: Array of Strings
   */
  public static let availableThemes: [String] = {
    let paths = Bundle(for: SyntaxHighlightRender.self).paths(forResourcesOfType: "css", inDirectory: nil) as [NSString]
    return paths.map{$0.lastPathComponent.replacingOccurrences(of: ".min.css", with: "")}
  }()

  public var theme: Theme

  public init(theme: Theme = .default) {
    self.theme = theme
  }

  /**
   Takes a String and returns a NSAttributedString with the given language highlighted.
   - parameter code:           Code to highlight.
   - parameter languageName:   Language name or alias. Set to `nil` to use auto detection.
   - parameter fastRender:     Defaults to true - When *true* will use the custom made html parser rather than Apple's solution.
   - returns: NSAttributedString with the detected code highlighted.
   */
  public func highlight(_ code: String, as language: String, fastRender: Bool = true) -> NSAttributedString? {
    guard let parsedCode = SyntaxHighlightParser.parse(code, as: language) else { return nil }
    return fastRender
      ? processHTMLString(parsedCode)
      : {
        let str = "<style>"
          + theme.lightTheme
          + "</style><pre><code class=\"hljs\">"
          + parsedCode
          + "</code></pre>"
        let opt: [String : Any] = [
          NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
          NSCharacterEncodingDocumentAttribute: String.Encoding.utf8]
        let data = str.data(using: String.Encoding.utf8)!
        return try? NSMutableAttributedString(data:data,options:opt as [String:AnyObject],documentAttributes:nil)
      }()
  }

  fileprivate let htmlStart = "<"
  fileprivate let spanStart = "span class=\""
  fileprivate let spanStartClose = "\">"
  fileprivate let spanEnd = "/span>"
  fileprivate let htmlEscape = try! NSRegularExpression(pattern: "&#?[a-zA-Z0-9]+?;", options: .caseInsensitive)

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
