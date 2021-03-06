//
//  SearchRepositoryTableViewCell.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class SearchRepositoryTableViewCell: UITableViewCell, ValueCell {
  internal func configureWith(value: Repository) {
    self.textLabel?.text = value.full_name
  }
}

