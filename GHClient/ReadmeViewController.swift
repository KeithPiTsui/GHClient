//
//  ReadmeViewController.swift
//  GHClient
//
//  Created by Pi on 13/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class ReadmeViewController: UIViewController {
  internal static func instantiate() -> ReadmeViewController {
    return Storyboard.Readme.instantiate(ReadmeViewController.self)
  }

  private let viewModel: ReadmeViewModelType = ReadmeViewModel()

  @IBOutlet weak var webView: UIWebView!

  internal func set(readmeUrl: URL) {
    self.viewModel.inputs.set(readmeURL: readmeUrl)
  }

  internal func set(readmeData: Data) {

  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.viewModel.inputs.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  override func bindStyles() {
    super.bindStyles()
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.navigateURL.observeForUI().observeValues { [weak self](url) in
      self?.webView.loadRequest(URLRequest(url: url))
    }
  }
}

extension ReadmeViewController: UIWebViewDelegate {

}



































