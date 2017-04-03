//
//  RepositoryDescriptionTableViewCell.swift
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

internal final class RepositoryDescriptionTableViewCell: UITableViewCell, ValueCell {

  override func awakeFromNib() {
    super.awakeFromNib()
    self.textLabel?.numberOfLines = 0
  }

  func configureWith(value: String) {
    self.textLabel?.text = value
  }
}
