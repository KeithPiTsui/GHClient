//
//  CommitChangesTableViewCell.swift
//  GHClient
//
//  Created by Pi on 30/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveCocoa
import Prelude_UIKit
import Ladder

internal final class CommitChangesTableViewCell: UITableViewCell, ValueCell {
  internal typealias CommitChangesConfig = ([Commit.CFile], CommitChangesTableViewCell.CommitChangesType)
  internal enum CommitChangesType {
    case additions
    case deletions
    case modifications
    case allFiles
    case allDiffs
  }

  func configureWith(value: CommitChangesTableViewCell.CommitChangesConfig) {
    

  }
}
