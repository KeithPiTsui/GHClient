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

    self.textView = KTCodeTextView() //UITextView(frame: codeViewContainer.bounds, textContainer: textContainer)
    self.textView.isEditable = false
    self.textView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    self.textView.autocorrectionType = .no
    self.textView.autocapitalizationType = .none
    self.textView.textColor = UIColor.white
    self.codeViewContainer.addSubview(self.textView)
    self.textView.text = self.code
    if let lang = self.language {
      self.textView.language = lang
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

  }
}
