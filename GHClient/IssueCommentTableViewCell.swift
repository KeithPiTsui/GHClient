//
//  IssueCommentTableViewCell.swift
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

internal final class IssueCommentTableViewCell: UITableViewCell, ValueCell {
  func configureWith(value: IssueComment) {
    self.textLabel?.text = value.body
  }
}
