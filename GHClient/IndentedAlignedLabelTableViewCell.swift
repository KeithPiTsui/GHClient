//
//  IndentedAlignedLabelTableViewCell.swift
//  GHClient
//
//  Created by Pi on 11/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

internal final class IndentedAlignedLabelTableViewCell: UITableViewCell, ValueCell {
  @IBOutlet weak var left: UILabel!
  @IBOutlet weak var right: UILabel!

  func configureWith(value: (String, String)) {
    left.text = value.0
    right.text = value.1
  }

}
