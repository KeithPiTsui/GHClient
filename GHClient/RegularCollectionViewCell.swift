//
//  RegularCollectionViewCell.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

internal final class RegularCollectionViewCell: UICollectionViewCell, ValueCell {
    @IBOutlet weak var textLabel: UILabel!
    
    func configureWith(value: String) {
        self.textLabel.text = value
    }
}
