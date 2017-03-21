//
//   Configure the view for the selected state   }    BranchLiteTableViewCell.swift
//  GHClient
//
//  Created by Pi on 21/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class BranchLiteTableViewCell: UITableViewCell, ValueCell {

  internal var section: Int = 0
  internal var row: Int = 0
  internal weak var dataSource: ValueCellDataSource? = nil

  func configureWith(value: BranchLite) {
    self.textLabel?.text = value.name
  }

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
}
