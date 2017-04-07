//
//  ViewController.swift
//  Demo
//
//  Created by Pi on 07/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import Highlighter

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    let codeTextView = KTCodeTextView()
    codeTextView.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(codeTextView)
    codeTextView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
    codeTextView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
    codeTextView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    codeTextView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive = true
    guard let str = try? String(contentsOf: Bundle.main.url(forResource: "demo", withExtension: "txt")!) else { return }
    codeTextView.text = str
  }

}

