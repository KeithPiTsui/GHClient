//
//  RepositoryIssuesTableViewCell.swift
//  GHClient
//
//  Created by Pi on 26/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveCocoa
import Prelude_UIKit
import Ladder

internal final class RepositoryIssuesTableViewCell: UITableViewCell, ValueCell {

  func configureWith(value: (Void, [Issue]?)) {
    self.textLabel?.text = "Issues"
  }
}
