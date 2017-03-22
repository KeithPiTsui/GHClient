//
//  RegularBaseTableViewCell.swift
//  GHClient
//
//  Created by Pi on 11/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

internal final class RegularBaseTableViewCell: UITableViewCell, ValueCell {
  func configureWith(value: (UIImage?, String)) {
    self.imageView?.image = value.0
    self.textLabel?.text = value.1
  }
}
