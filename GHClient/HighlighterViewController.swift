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

  internal var textView: KTCodeTextView!
  internal var code = ""
  internal var language: String?

  override func viewDidLoad() {
    super.viewDidLoad()
    guard  let lang = self.language else { return }

    self.textView = KTCodeTextView(language: lang)
    self.textView.isEditable = false
    self.textView.showParagraphNumbers = true
    self.codeViewContainer.addSubview(self.textView)
    self.textView.fillupSuperView()
    self.textView.text = self.code
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

  }
}
