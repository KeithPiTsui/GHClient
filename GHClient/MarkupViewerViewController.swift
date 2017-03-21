//
//  MarkupViewerViewController.swift
//  GHClient
//
//  Created by Pi on 21/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

internal final class MarkupViewerViewController: UIViewController {

  fileprivate let viewModel: MarkupViewerViewModelType = MarkupViewerViewModel()
  @IBOutlet weak var webView: UIWebView!

  internal static func instantiate() -> MarkupViewerViewController {
    return Storyboard.MarkupViewer.instantiate(MarkupViewerViewController.self)
  }

  internal func set(markup url: URL) {
    self.viewModel.inputs.set(markup: url)
  }


  override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  override func bindStyles() {
    super.bindStyles()
  }

  override func bindViewModel() {
    super.bindViewModel()
    self.viewModel.outpus.htmlString.observeForUI().observeValues { [weak self] in
      self?.webView.loadHTMLString($0, baseURL: nil)
    }
  }
}

extension MarkupViewerViewController: UIWebViewDelegate {
  
}
