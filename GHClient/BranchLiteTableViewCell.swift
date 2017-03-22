//
//  BranchLiteTableViewCell.swift
//  GHClient
//
//  Created by Pi on 21/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class BranchLiteTableViewCell: UITableViewCell, ValueCell {
  func configureWith(value: BranchLite) {
    self.textLabel?.text = value.name
  }
}
