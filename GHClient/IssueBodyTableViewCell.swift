//
//  IssueBodyTableViewCell.swift
//  GHClient
//
//  Created by Pi on 24/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveCocoa
import Prelude_UIKit
import Ladder
import Down

internal final class IssueBodyTableViewCell: UITableViewCell, ValueCell {

  internal var bodyLabel: DownView? //UITextView() //GHCAttributedLabel(frame: CGRect.zero)

  override func awakeFromNib() {
    super.awakeFromNib()
    self.bodyLabel = try? DownView(frame: CGRect.zero, markdownString: "")
//    self.bodyLabel.font = UIFont.systemFont(ofSize: 14)
//    self.bodyLabel.translatesAutoresizingMaskIntoConstraints = false
//    self.bodyLabel.numberOfLines = 0
//    self.bodyLabel.detectors = [GuitarChord.atUser:"users", GuitarChord.url:""]
    self.contentView.addSubview(self.bodyLabel!)
    self.bodyLabel?.fillupSuperView()
    self.bodyLabel?.scrollView.isScrollEnabled = false
  }

  func configureWith(value: String) {
//    try? self.bodyLabel.set(markup: value)
//    guard let attributedString = try? Down(markdownString: value).toAttributedString() else { return }
//    self.bodyLabel.attributedText = attributedString
    try? self.bodyLabel?.update(markdownString: value, didLoadSuccessfully: nil) {
      DispatchQueue.main.async {
        self.tableView?.setNeedsLayout()
      }
    }
  }
}








