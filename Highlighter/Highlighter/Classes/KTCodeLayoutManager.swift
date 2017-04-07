//
//  KTCodeLayoutManager.swift
//  Highlighter
//
//  Created by Pi on 07/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

public final class KTCodeLayoutManager: NSLayoutManager {
  public static let paragraphNumberInset: CGFloat = 16
  public var showParagraphNumbers = false { didSet{ self.invalidateWholeLayout() } }
  public var tabWidth: CGFloat = 2 { didSet{ self.invalidateWholeLayout() } }
  public var lineHeight: CGFloat = 1 { didSet{ self.invalidateWholeLayout() } }


  fileprivate func invalidateWholeLayout() {
      guard let textStorage = self.textStorage else { fatalError("Have not set text storage for this layout manager") }
      self.invalidateLayout(forCharacterRange: NSRange(location: 0, length: textStorage.length),
                            actualCharacterRange: nil)
  }


// MARK: -
// MARK: layout computation

  public func insetsForLine(startingAt charaterIndex: Int) -> UIEdgeInsets {
    var leftInset: CGFloat = 0;
    if self.showParagraphNumbers {
      leftInset += KTCodeLayoutManager.paragraphNumberInset
    }
//    guard let str = self.textStorage?.string else { fatalError("Have not set text storage for this layout manager") }
//    let text = str as NSString
//    let paragraphRange = text.paragraphRange(for: NSRange(location: charaterIndex, length: 0))
//    if paragraphRange.location < charaterIndex {
//      // Get the first glyph index in the paragraph
//      let firstGlyphIndex = self .glyphIndexForCharacter(at: paragraphRange.location)
//
//      // Get the first line of the paragraph
//      var firstLineGlyphRange = NSRange()
//      self .lineFragmentRect(forGlyphAt: firstGlyphIndex, effectiveRange: &firstLineGlyphRange)
//      let firstLineCharRange = self .characterRange(forGlyphRange: firstLineGlyphRange, actualGlyphRange: nil)
//
//      // Find the first wrapping char and wrap one char behind
//      var wrappingCharIndex = NSNotFound
//      let cs = CharacterSet(charactersIn: "({[")
//      wrappingCharIndex = text.rangeOfCharacter(from: cs, 
//                                                options: [],
//                                                range: firstLineCharRange).location
//      if wrappingCharIndex != NSNotFound {
//        wrappingCharIndex += 1
//      } else { // Alternatively, fall back to the first text char
//        wrappingCharIndex = text.rangeOfCharacter(from: CharacterSet.whitespaces.inverted,
//                                                  options: [],
//                                                  range: firstLineCharRange).location
//        if wrappingCharIndex != NSNotFound {
//          wrappingCharIndex += 4
//        }
//      }
//
//      // Wrapping char found, determine indent
//      if wrappingCharIndex != NSNotFound  {
//        let firstTextGlyphIndex = self.glyphIndexForCharacter(at: wrappingCharIndex)
//        leftInset += self.location(forGlyphAt: firstTextGlyphIndex).x - self.location(forGlyphAt: firstGlyphIndex).x
//      }
//    }

    return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0)
  }
}

// MARK: -
// MARK: layout Handling
extension KTCodeLayoutManager: NSLayoutManagerDelegate {
  public func layoutManager(_ layoutManager: NSLayoutManager,
                            lineSpacingAfterGlyphAt glyphIndex: Int,
                            withProposedLineFragmentRect rect: CGRect) -> CGFloat {
    // Line height is a multiple of the complete line, here we need only the extra space
      return (max(self.lineHeight, 1) - 1) * rect.size.height
  }

  public override func setLineFragmentRect(_ fragmentRect: CGRect,
                                           forGlyphRange glyphRange: NSRange,
                                           usedRect: CGRect) {
    // IMPORTANT: Perform the shift of the X-coordinate that cannot be done 
    // in NSTextContainer's -lineFragmentRectForProposedRect:atIndex:writingDirection:remainingRect:
    let insets = self.insetsForLine(startingAt: self.characterIndexForGlyph(at: glyphRange.location))
    var fragmentRect = fragmentRect
    fragmentRect.origin.x += insets.left
    var usedRect = usedRect
    usedRect.origin.x += insets.left
    super.setLineFragmentRect(fragmentRect, forGlyphRange: glyphRange, usedRect: usedRect)
  }

  public override func setExtraLineFragmentRect(_ fragmentRect: CGRect, usedRect: CGRect, textContainer container: NSTextContainer) {
    guard let textStorage = self.textStorage else { fatalError("Have not set text storage for this layout manager") }
    let insets = self.insetsForLine(startingAt: textStorage.length)
    var fragmentRect = fragmentRect
    fragmentRect.origin.x = insets.left
    var usedRect = usedRect
    usedRect.origin.x = insets.left
    super.setExtraLineFragmentRect(fragmentRect, usedRect: usedRect, textContainer: container)
  }

  public func layoutManager(_ layoutManager: NSLayoutManager,
                            shouldUse action: NSControlCharacterAction,
                            forControlCharacterAt charIndex: Int)
    -> NSControlCharacterAction {
      guard let str = self.textStorage?.string else { fatalError("Have not set text storage for this layout manager") }
      let text = str as NSString
      if String(text.character(at: charIndex)) == "\t"  {
        return .whitespace
      }
      return action
  }

//  public func layoutManager(_ layoutManager: NSLayoutManager,
//                            boundingBoxForControlGlyphAt glyphIndex: Int,
//                            for textContainer: NSTextContainer,
//                            proposedLineFragment proposedRect: CGRect,
//                            glyphPosition: CGPoint,
//                            characterIndex charIndex: Int)
//    -> CGRect {
//      guard let textStorage = self.textStorage else { fatalError("Have not set text storage for this layout manager") }
//
//
//      var rect = CGRect.zero
//      rect.origin = glyphPosition
//      rect.size.width = glyphPosition.x
//
//      return rect
//  }

}


// MARK: -
// MARK: Drawing

extension KTCodeLayoutManager {
  public override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
    super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
    if self.showParagraphNumbers {
      self.drawParagraphNumbers(for: glyphsToShow, at: origin)
    }
  }

  internal func drawParagraphNumbers(for glyphRange: NSRange, at origin: CGPoint ) {

    guard let textStorage = self.textStorage else { fatalError("Have not set text storage for this layout manager") }
    let text = textStorage.string as NSString

    // Enumerate all lines
    var glyphIndex = glyphRange.location

    while glyphIndex < NSMaxRange(glyphRange) {
      var glyphLineRange = NSRange()
      let lineFragmentRect = self.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: &glyphLineRange)

      // Check for paragraph start
      let lineRange = self.characterRange(forGlyphRange: glyphLineRange, actualGlyphRange: nil)
      let paragraphRange = text.paragraphRange(for: lineRange)

      // Draw paragraph number if we're at the start of a paragraph
      if lineRange.location == paragraphRange.location {
        self.drawParagraphNumber(for: paragraphRange, lineFragmentRect: lineFragmentRect, at: origin)
      }

      // Advance
      glyphIndex = NSMaxRange(glyphLineRange)
    }
  }

  internal func drawParagraphNumber(for charRange: NSRange, lineFragmentRect lineRect: CGRect, at origin: CGPoint) {
    guard let textStorage = self.textStorage as? KTCodeTextStorage else { return }
    let paragraphNumber = textStorage.paragraphNumber(at: charRange.location)
    let numberString = NSString(format: "%lu", paragraphNumber)
    let attributes = [NSForegroundColorAttributeName: UIColor.gray, NSFontAttributeName: UIFont.systemFont(ofSize: 9)]
    let height = numberString.boundingRect(with: CGSize(width:1000,height:1000), options: [], attributes: attributes, context: nil).size.height
    var numberRect = CGRect.zero
    numberRect.size.width = lineRect.origin.x
    numberRect.origin.x = origin.x
    numberRect.size.height = height
    numberRect.origin.y = lineRect.midY - height * 0.5 + origin.y
    numberString.draw(with: numberRect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
  }

}














































