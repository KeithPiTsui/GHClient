//
//  KTCodeLayoutManager.swift
//  Highlighter
//
//  Created by Pi on 07/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

public final class KTCodeLayoutManager: NSLayoutManager {
  internal var paragraphNumberInset: CGFloat = 24 { didSet{ self.invalidateWholeLayout() } }
  public var showParagraphNumbers = false { didSet{ self.invalidateWholeLayout() } }
  public var lineHeight: CGFloat = 1 { didSet{ self.invalidateWholeLayout() } }


  internal func invalidateWholeLayout() {
      guard let textStorage = self.textStorage else { fatalError("Have not set text storage for this layout manager") }
      self.invalidateLayout(forCharacterRange: NSRange(location: 0, length: textStorage.length),
                            actualCharacterRange: nil)
  }


// MARK: -
// MARK: layout computation

  public func insetsForLine(startingAt charaterIndex: Int) -> UIEdgeInsets {
    var leftInset: CGFloat = 0;
    if self.showParagraphNumbers {
      leftInset += self.paragraphNumberInset
    }
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
}


// MARK: -
// MARK: Drawing

extension KTCodeLayoutManager {
  public override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
    super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
    if self.showParagraphNumbers {
      autoreleasepool{
        self.drawLineNumberBackground(for: glyphsToShow, at: origin)
        self.drawParagraphNumbers(for: glyphsToShow, at: origin)
      }
    }
  }

  /// Enumerate all lines for a glyph range
  internal func enumerateLines(for glyphRange: NSRange, at origin: CGPoint, action: (CGRect, NSRange) -> () ) {
    var glyphIndex = glyphRange.location
    while glyphIndex < NSMaxRange(glyphRange) {
      var glyphLineRange = NSRange()
      let lineFragmentRect = self.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: &glyphLineRange)
      action(lineFragmentRect, glyphLineRange)
      // Advance
      glyphIndex = NSMaxRange(glyphLineRange)
    }
  }

  internal func drawLineNumberBackground(for glyphRange: NSRange, at origin: CGPoint ) {
    self.enumerateLines(for: glyphRange, at: origin) { (lineFragmentRect, _) in
      // Draw a vertical line after number
      let path = UIBezierPath()
      path.lineWidth = 1
      path.move(to: lineFragmentRect.origin)
      path.addLine(to: CGPoint(x: lineFragmentRect.origin.x, y: lineFragmentRect.origin.y + lineFragmentRect.height))
      UIColor.gray.set()
      path.stroke()

      // Draw background color for line number
      var lineNumberArea = CGRect.zero
      lineNumberArea.origin = lineFragmentRect.origin
      lineNumberArea.origin.x = 0
      lineNumberArea.size.width = lineFragmentRect.origin.x
      lineNumberArea.size.height = lineFragmentRect.height
      let area = UIBezierPath(rect: lineNumberArea)
      UIColor.yellow.set()
      area.fill()
    }
  }

  internal func drawParagraphNumbers(for glyphRange: NSRange, at origin: CGPoint ) {
    guard let textStorage = self.textStorage else { fatalError("Have not set text storage for this layout manager") }
    let text = textStorage.string as NSString
    self.enumerateLines(for: glyphRange, at: origin) { (lineFragmentRect, glyphLineRange) in
      // Check for paragraph start
      let lineRange = self.characterRange(forGlyphRange: glyphLineRange, actualGlyphRange: nil)
      let paragraphRange = text.paragraphRange(for: lineRange)

      // Draw paragraph number if we're at the start of a paragraph
      if lineRange.location == paragraphRange.location {
        self.drawParagraphNumber(for: paragraphRange, lineFragmentRect: lineFragmentRect, at: origin)
      }
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














































