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
  fileprivate let ktLayoutManager: KTCodeLayoutManager

  public var paragraphNumberInset: CGFloat = 24 { didSet{ self.ktLayoutManager.paragraphNumberInset = self.paragraphNumberInset } }
  public var showParagraphNumbers = false { didSet{ self.ktLayoutManager.showParagraphNumbers = self.showParagraphNumbers } }
  public var lineHeight: CGFloat = 1.1 { didSet{ self.ktLayoutManager.lineHeight = self.lineHeight } }

  public init(language: String) {
    self.ktTextStorage = KTCodeTextStorage(language: language)
    self.ktLayoutManager = KTCodeLayoutManager()
    self.ktTextStorage.addLayoutManager(self.ktLayoutManager)
    let textContainer = KTCodeTextContainer(size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
    self.ktLayoutManager.addTextContainer(textContainer)

    super.init(frame: CGRect.zero, textContainer: textContainer)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
