//
//  KTCodeTextView.swift
//  Highlighter
//
//  Created by Pi on 07/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

public final class KTCodeTextView: UITextView {

  fileprivate let ktTextStorage: KTCodeTextStorage

  public init(language: String) {
    self.ktTextStorage = KTCodeTextStorage(language: language)
    let layoutManager = KTCodeLayoutManager()
    self.ktTextStorage.addLayoutManager(layoutManager)
    let textContainer = KTCodeTextContainer(size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
    layoutManager.addTextContainer(textContainer)

    layoutManager.lineHeight = 1.1
    layoutManager.showParagraphNumbers = true
    layoutManager.tabWidth = 4

    super.init(frame: CGRect.zero, textContainer: textContainer)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
