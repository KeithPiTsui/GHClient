//
//  RegularCollectionViewCell.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class RegularCollectionViewCell: UICollectionViewCell, ValueCell {
    
    
    internal var section: Int = 0
    internal var row: Int = 0
    internal weak var dataSource: ValueCellDataSource? = nil
    
    
    @IBOutlet weak var textLabel: UILabel!
    
    func configureWith(value: CustomStringConvertible) {
        self.textLabel.text = value.description
    }
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue
            if newValue {
                self.textLabel.textColor = UIColor.red
            } else {
                self.textLabel.textColor = UIColor.black
            }
        }
    }
}
