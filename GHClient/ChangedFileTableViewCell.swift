//
//  ChangedFileTableViewCell.swift
//  GHClient
//
//  Created by Pi on 10/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveCocoa
import Prelude_UIKit
import Ladder

internal final class ChangedFileTableViewCell: UITableViewCell, ValueCell {

  func configureWith(value: Commit.CFile) {
    self.textLabel?.text = value.filename
  }
}
