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
    internal func configureWith(value: NumberRange) {
        self.leftNumberTF.text = "\(value.0)"
        self.rightNumberTF.text = "\(value.1)"
    }
    
    @IBOutlet weak var leftNumberTF: UITextField!
    
    @IBOutlet weak var rightNumberTF: UITextField!
    
    
}
