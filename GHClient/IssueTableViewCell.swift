//
//  IssueTableViewCell.swift
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
import TTTAttributedLabel

internal final class IssueTableViewCell: UITableViewCell, ValueCell {

  @IBOutlet weak var userAvatar: UIImageView!
  @IBOutlet weak var IssueBrief: TTTAttributedLabel!

  func configureWith(value: Issue) {
    self.IssueBrief.text = value.user.login
  }

}
