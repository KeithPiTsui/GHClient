//
//  NumberRangeCollectionViewCell.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI


internal final class NumberRangeCollectionViewCell: UICollectionViewCell, ValueCell {
    
    internal var section: Int = 0
    internal var row: Int = 0
    internal weak var dataSource: ValueCellDataSource? = nil
    
    internal func configureWith(value: ComparativeArgument<UInt>) {
        if let leftNum = value.lower {
            self.leftNumberTF.text = "\(leftNum)"
        }
        if let rightNum = value.upper {
            self.rightNumberTF.text = "\(rightNum)"
        }
    }
    
    @IBOutlet weak var leftNumberTF: UITextField!
    
    @IBOutlet weak var rightNumberTF: UITextField!
}

extension NumberRangeCollectionViewCell: UITextFieldDelegate {
    internal func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        let leftNum = UInt(leftNumberTF.text ?? "")
        let rightNum = UInt(rightNumberTF.text ?? "")
        
        var ca: ComparativeArgument<UInt>? = nil
        switch (leftNum, rightNum) {
        case let (l?, r?):
            if l == r {
                ca = ComparativeArgument.equal(l)
            } else {
                ca = ComparativeArgument.between(l, r)
            }
        case let (l?, nil):
            ca = ComparativeArgument.biggerAndEqualThan(l)
        case let (nil, r?):
            ca = ComparativeArgument.lessAndEqualThan(r)
        default:
            break
        }
        guard let ca0 = ca else { return }
        
        self.dataSource?.set(value: ca0,
                             cellClass: NumberRangeCollectionViewCell.self,
                             inSection: self.section,
                             row: self.row)
        
    }
}
