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

  var highlightr : Highlightr!
  let textStorage = CodeAttributedString()
  var textView: UITextView!


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

    let code = try! String.init(contentsOfFile: Bundle.main.path(forResource: "sampleCode", ofType: "txt")!)
    self.textView.text = code

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
