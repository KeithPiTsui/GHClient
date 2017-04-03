//
//  GHCAttributedLabel.swift
//  GHClient
//
//  Created by Pi on 25/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import Down
import Curry
import Prelude
import Ji

internal final class GHCAttributedLabel: TTTAttributedLabel {

  override init(frame: CGRect = CGRect.zero) {
    super.init(frame: frame)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var baseURL: URL = AppEnvironment.current.apiService.serverConfig.apiBaseUrl
  var detectors: [GuitarChord:String] = [:]

  fileprivate func firstTag(_ tag: String, in html: String) -> Range<String.Index>? {
    return self.firstPart("<\(tag)", end: ">", in: html)
  }

  fileprivate func firstAttribute(_ attr: String, in tag: String) -> Range<String.Index>? {
    return self.firstPart("\(attr)=\"", end: "\"", in: tag)
  }

  fileprivate func firstPart(_ begin: String,
                             end: String,
                             in whole: String,
                             with searchRange: Range<String.Index>? = nil) -> Range<String.Index>? {
    guard let range = whole.range(of: begin, options: [], range: searchRange, locale: nil) else { return nil }
    let endIndex = searchRange?.upperBound ?? whole.endIndex
    let subRange = Range(uncheckedBounds: (range.upperBound, endIndex))
    guard let r = whole.range(of: end, options: [], range: subRange, locale: nil) else { return nil }
    return Range(uncheckedBounds: (range.lowerBound, r.upperBound))
  }


  internal func set(markup: String) throws {
    let down = Down(markdownString: markup)
    var html = try down.toHTML()

    while let range = self.firstTag("img", in: html) {
      let substr = html.substring(with: range)
      var src = ""
      if let srcRange = self.firstAttribute("src", in: substr) {
        src = substr.substring(with: srcRange)
          .trimLeft(byRemoving: "src=\"".length())
          .trimRight(byRemoving: 1)
      }
      var alt = ""
      if let altRange = self.firstAttribute("alt", in: substr) {
        alt = substr.substring(with: altRange)
          .trimLeft(byRemoving: "alt=\"".length())
          .trimRight(byRemoving: 1)
      }
      let link = "<a href=\(src)>\(alt)</a>"
      html.replaceSubrange(range, with: link)
    }

    guard let data = html.data(using: String.Encoding.utf8) else {
      throw DownErrors.htmlDataConversionError
    }

    let options: [String: Any] = [
      NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
      NSCharacterEncodingDocumentAttribute: NSNumber(value: String.Encoding.utf8.rawValue)
    ]
    let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)

    super.setText(attributedString)
    let plain = attributedString.string as NSString
    try self.detectors.keys
      .forEach { (chord) in
        let range = NSRange(location: 0, length: plain.length)
        let regex = try NSRegularExpression(pattern: chord.rawValue, options: [])
        let matches = regex.matches(in: plain as String, options: [], range: range)
        let ranges = matches.flatMap {$0.range}
        let chordURL = curry(self.url(for: with:))(chord)
        let urls = ranges.map(plain.substring(with:)).map(chordURL)
        zip(ranges, urls).forEach{ (range, url) in
          self.addLink(to: url, with: range)
        }
    }
  }

  private func url(for chord: GuitarChord, with id: String) -> URL {
    var url = self.baseURL
    let pathComponent = self.detectors[chord]!
    var cs = CharacterSet.punctuationCharacters
    cs.formUnion(.whitespacesAndNewlines)
    let trimedId = id.trimmingCharacters(in: cs)
    switch chord {
    case .atUser:
      url.appendPathComponent(pathComponent)
      url.appendPathComponent("\(trimedId)")
    case .url:
      url = URL(string: trimedId) ?? url
    default:
      break
    }
    return url
  }
}
