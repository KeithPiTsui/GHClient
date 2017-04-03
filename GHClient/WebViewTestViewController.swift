//
//  WebViewTestViewController.swift
//  GHClient
//
//  Created by Pi on 02/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import Down

class WebViewTestViewController: UIViewController {

  internal var bodyLabel = MarkupView()
  internal var scrollView = UIScrollView()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.addSubview(self.scrollView)
    self.scrollView.frame = self.view.frame
    self.scrollView.addSubview(self.bodyLabel)
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    frame.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height / 2)
    self.bodyLabel.frame = frame
    self.bodyLabel.scrollView.isScrollEnabled = false
    self.bodyLabel.webPageScale = 0.8
    self.scrollView.contentSize = CGSize(width: 414, height: 1050)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let bundle = Bundle(for: WebViewTestViewController.self)
    if let url = bundle.url(forResource: "test", withExtension: "markup") {
      if let markup = try? String(contentsOf: url) {
        try? self.bodyLabel.update(markdown: markup)
      }
    }
    print("Okay")
  }
}
