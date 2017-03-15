//
//  IndentedAlignedLabelTableViewCell.swift
//  GHClient
//
//  Created by Pi on 11/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

internal final class IndentedAlignedLabelTableViewCell: UITableViewCell, ValueCell {

  internal var section: Int = 0
  internal var row: Int = 0
  internal weak var dataSource: ValueCellDataSource? = nil

  @IBOutlet weak var left: UILabel!
  @IBOutlet weak var right: UILabel!

  func configureWith(value: (String, String)) {
    left.text = value.0
    right.text = value.1
  }


  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
