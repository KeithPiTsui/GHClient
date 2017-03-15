//
//  RegularTextFieldCollectionViewCell.swift
//  GHClient
//
//  Created by Pi on 08/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

internal final class RegularTextFieldCollectionViewCell: UICollectionViewCell, ValueCell {
  internal var section: Int = 0
  internal var row: Int = 0
  internal weak var dataSource: ValueCellDataSource? = nil
  @IBOutlet weak var textField: UITextField!

  func configureWith(value: String) {
    self.textField.text = value
  }
}


extension RegularTextFieldCollectionViewCell: UITextFieldDelegate {
  internal func textFieldDidEndEditing(_ textField: UITextField) {
    print("textFieldDidEndEditing")
    guard let text = self.textField.text, text.isEmpty == false else { return }
    self.dataSource?.set(value: text,
                         cellClass: RegularTextFieldCollectionViewCell.self,
                         inSection: self.section,
                         row: self.row)

  }
}
