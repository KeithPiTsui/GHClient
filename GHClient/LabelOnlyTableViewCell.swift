//
//  LabelOnlyTableViewCell.swift
//  GHClient
//
//  Created by Pi on 11/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

internal final class LabelOnlyTableViewCell: UITableViewCell, ValueCell {
  func configureWith(value: String) {
    self.textLabel?.text = value
  }
}
