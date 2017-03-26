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

internal final class GHCAttributedLabel: TTTAttributedLabel {

  var baseURL: URL = AppEnvironment.current.apiService.serverConfig.apiBaseUrl
  var detectors: [GuitarChord:String] = [:]

  internal func set(markup: String) throws {
    let attributedString = try Down(markdownString: markup).toAttributedString()
//    super.setText(attributedString)
    super.setText(attributedString) {$0}
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
    switch chord {
    case .atUser:
      url.appendPathComponent(pathComponent)
    default:
      break
    }
    url.appendPathComponent("\(id.trim())")
    return url
  }
}
