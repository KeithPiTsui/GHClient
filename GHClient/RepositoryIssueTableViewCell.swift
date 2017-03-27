
//
//  RepositoryIssueTableViewCell.swift
//  GHClient
//
//  Created by Pi on 27/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveCocoa
import Prelude_UIKit
import Ladder

internal final class RepositoryIssueTableViewCell: UITableViewCell, ValueCell {

  func configureWith(value: Issue) {
    self.textLabel?.text = value.title
  }
}
