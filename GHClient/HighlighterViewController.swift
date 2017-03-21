//
//  HighlighterViewController.swift
//  GHClient
//
//  Created by Pi on 20/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import Highlighter

internal final class HighlighterViewController: UIViewController {

  internal static func instantiate() -> HighlighterViewController {
    return Storyboard.Highlighter.instantiate(HighlighterViewController.self)
  }

  @IBOutlet weak var codeViewContainer: UIView!

  internal var highlightr : Highlightr!
  internal let textStorage = CodeAttributedString()
  internal var textView: UITextView!
  internal var code: String = try! String.init(contentsOfFile: Bundle.main.path(forResource: "sampleCode", ofType: "txt")!)


  override func viewDidLoad() {
    super.viewDidLoad()
    self.textStorage.language = "swift"

    let layoutManager = NSLayoutManager()
    let textContainer = NSTextContainer(size: view.bounds.size)
    layoutManager.addTextContainer(textContainer)
    self.textStorage.addLayoutManager(layoutManager)

    self.textView = UITextView(frame: codeViewContainer.bounds, textContainer: textContainer)
    self.textView.isEditable = false
    self.textView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    self.textView.autocorrectionType = .no
    self.textView.autocapitalizationType = .none
    self.textView.textColor = UIColor.white
    self.codeViewContainer.addSubview(self.textView)
    self.textView.text = self.code

    self.highlightr = self.textStorage.highlightr
    self.updateColors()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

  }

  fileprivate func updateColors()
  {
    self.textView.backgroundColor = self.highlightr.theme.themeBackgroundColor
  }
}
