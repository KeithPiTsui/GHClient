//
//  RepositoryStargazersTableViewCell.swift
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

internal final class RepositoryStargazersTableViewCell: UITableViewCell, ValueCell {

  func configureWith(value: [UserLite]?) {
    self.textLabel?.text = "Stargazers"
  }
}
