//
//  KTCodeTextStorage.swift
//  Highlighter
//
//  Created by Pi on 07/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import Foundation

public final class KTCodeTextStorage: NSTextStorage {
  /// Internal Storage
  fileprivate let content = NSTextStorage() //NSMutableAttributedString()

  fileprivate let highlighter = SyntaxHighlightRender()

  /// Language syntax to use for highlighting. Providing nil will disable highlighting.
  public var language : String { didSet{ highlight(NSMakeRange(0, content.length)) } }

  public init(language: String) {
    self.language = language
    super.init()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Returns a standard String based on the current one.
  public override var string: String { get { return content.string } }

  /**
   Returns the attributes for the character at a given index.

   - parameter location: Int
   - parameter range:    NSRangePointer

   - returns: Attributes
   */
  public override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [String : Any] {
    return content.attributes(at: location, effectiveRange: range)
  }

  /**
   Replaces the characters at the given range with the provided string.

   - parameter range: NSRange
   - parameter str:   String
   */
  public override func replaceCharacters(in range: NSRange, with str: String) {
    content.replaceCharacters(in: range, with: str)
    self.edited(.editedCharacters,
                range: range,
                changeInLength: (str as NSString).length - range.length)
  }

  /**
   Sets the attributes for the characters in the specified range to the given attributes.

   - parameter attrs: [String : AnyObject]
   - parameter range: NSRange
   */
  public override func setAttributes(_ attrs: [String : Any]?, range: NSRange) {
    content.setAttributes(attrs, range: range)
    self.edited(.editedAttributes,
                range: range,
                changeInLength: 0)
  }

  /// Called internally everytime the string is modified.
  public override func processEditing() {
    super.processEditing()
    if self.editedMask.contains(.editedCharacters) {
      let string = self.string as NSString
      let range = string.paragraphRange(for: editedRange)
      self.highlight(range)
    }
  }

  let serialQueue = DispatchQueue(label: "highlighter_serial_queue")


  fileprivate func highlight(_ range: NSRange) {
    guard self.language.isEmpty == false else { return }
    guard self.content.length > 0 else { return }
    let string = (self.string as NSString)
    let line = string.substring(with: range)
    self.serialQueue.async {
      guard let tmpStrg = self.highlighter.highlight(line, as: self.language) else { return }
      DispatchQueue.main.async {
        //Checks to see if this highlighting is still valid.
        if((range.location + range.length) > self.content.length) { return }
        if(tmpStrg.string != self.content.attributedSubstring(from: range).string) { return }

        self.beginEditing()
        tmpStrg.enumerateAttributes(
          in: NSMakeRange(0, tmpStrg.length),
          options: []) { (attrs, locRange, stop) in
            var fixedRange = NSMakeRange(range.location+locRange.location, locRange.length)
            fixedRange.length
              = (fixedRange.location + fixedRange.length < string.length)
              ? fixedRange.length
              : string.length-fixedRange.location
            fixedRange.length
              = (fixedRange.length >= 0)
              ? fixedRange.length
              : 0
            self.content.setAttributes(attrs, range: fixedRange)
        }
        self.endEditing()
        self.edited(.editedAttributes, range: range, changeInLength: 0)
      }
    }
  }
}

extension KTCodeTextStorage {
  internal func paragraphNumber(at index: Int) -> Int {
    var number = 1
    let str = self.content.string as NSString
    str.enumerateSubstrings(in: NSRange(location: 0, length: index),
                            options: [.byParagraphs, .substringNotRequired]) { _ in
      number += 1
    }
    return number
  }
}


































