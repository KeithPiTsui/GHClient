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

  @IBOutlet weak var bodyContainer: UIView!

  @IBOutlet weak var containerHeight: NSLayoutConstraint!

  internal var bodyLabel: TTTAttributedLabel?

  override func awakeFromNib() {
    super.awakeFromNib()

    self.bodyLabel = TTTAttributedLabel(frame: CGRect.zero)
    if let v = self.bodyLabel {
      v.delegate = self
      v.font = UIFont.systemFont(ofSize: 14)
      v.numberOfLines = 0
      v.translatesAutoresizingMaskIntoConstraints = false
      self.bodyContainer.addSubview(v)
      v.topAnchor.constraint(equalTo: self.bodyContainer.topAnchor).isActive = true
      v.bottomAnchor.constraint(equalTo: self.bodyContainer.bottomAnchor).isActive = true
      v.leftAnchor.constraint(equalTo: self.bodyContainer.leftAnchor).isActive = true
      v.rightAnchor.constraint(equalTo: self.bodyContainer.rightAnchor).isActive = true
    }
  }


  func configureWith(value: String) {
    guard let str = try? Down(markdownString: value).toAttributedString() else { return }
    self.bodyLabel?.setText(str)
  }
}

extension IssueBodyTableViewCell: TTTAttributedLabelDelegate {
  internal func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
    if let delegate = self.tableView?.delegate as? TTTAttributedLabelDelegate {
      delegate.attributedLabel?(label, didSelectLinkWith: url)
    }
  }
}








