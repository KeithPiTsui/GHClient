//
//  MarkupViewerViewController.swift
//  GHClient
//
//  Created by Pi on 21/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import Down

internal final class MarkupViewerViewController: UIViewController {

  fileprivate let viewModel: MarkupViewerViewModelType = MarkupViewerViewModel()
  fileprivate var webView: DownView?

  internal static func instantiate() -> MarkupViewerViewController {
    return Storyboard.MarkupViewer.instantiate(MarkupViewerViewController.self)
  }

  internal func set(markup url: URL) {
    self.viewModel.inputs.set(markup: url)
  }


  override func viewDidLoad() {
    super.viewDidLoad()

    if let wv = try? DownView(frame: CGRect.zero, markdownString: "") {
      self.view.addSubview(wv)
      self.webView = wv
      wv.translatesAutoresizingMaskIntoConstraints = false
      wv.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
      wv.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive = true
      wv.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
      wv.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }

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
      try? self?.webView?.update(markdownString: $0)
    }
  }
}

extension MarkupViewerViewController: UIWebViewDelegate {
  
}
