//
//  KTCodeTextContainer.swift
//  Highlighter
//
//  Created by Pi on 07/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

public final class KTCodeTextContainer: NSTextContainer {
  public override func lineFragmentRect(forProposedRect proposedRect: CGRect,
                                        at characterIndex: Int,
                                        writingDirection baseWritingDirection: NSWritingDirection,
                                        remaining remainingRect: UnsafeMutablePointer<CGRect>?)
    -> CGRect {
      var rect = super.lineFragmentRect(forProposedRect: proposedRect,
                                        at: characterIndex,
                                        writingDirection: baseWritingDirection,
                                        remaining: remainingRect)
      guard let layoutManager = self.layoutManager as? KTCodeLayoutManager else { return rect }
      let insets = layoutManager.insetsForLine(startingAt: characterIndex)
      rect.size.width -= insets.left + insets.right
      return rect
  }
}
