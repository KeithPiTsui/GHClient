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

internal final class IssueBodyTableViewCell: UITableViewCell, ValueCell {
  func configureWith(value: String) {
    self.textLabel?.text = value
  }
}
