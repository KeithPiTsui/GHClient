//
//  NumberRangeCollectionViewCell.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

internal typealias NumberRange = (Int?, Int?)

internal final class NumberRangeCollectionViewCell: UICollectionViewCell, ValueCell {
    
    internal var section: Int = 0
    internal var row: Int = 0
    internal weak var dataSource: ValueCellDataSource? = nil
    
    internal func configureWith(value: NumberRange) {
        if let leftNum = value.0 {
            self.leftNumberTF.text = "\(leftNum)"
        }
        if let rightNum = value.1 {
            self.rightNumberTF.text = "\(rightNum)"
        }
    }
    
    @IBOutlet weak var leftNumberTF: UITextField!
    
    @IBOutlet weak var rightNumberTF: UITextField!
}

extension NumberRangeCollectionViewCell: UITextFieldDelegate {
    internal func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        let leftNum = Int(leftNumberTF.text ?? "")
        let rightNum = Int(rightNumberTF.text ?? "")
        self.dataSource?.set(value: (leftNum, rightNum),
                             cellClass: NumberRangeCollectionViewCell.self,
                             inSection: self.section,
                             row: self.row)
        
    }
}
