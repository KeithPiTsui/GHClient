//
//  MenuGeneralCell.swift
//  GHClient
//
//  Created by Pi on 03/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

internal struct MenuItem {
    let icon: UIImage
    let name: String
}


internal final class MenuGeneralCell: UITableViewCell, ValueCell {

    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemIconView: UIImageView!

    func configureWith(value: MenuItem) {
        self.itemIconView.image = value.icon
        self.itemName.text = value.name
    }
    
    override func bindViewModel() {
        super.bindViewModel()
    }
 
    override func bindStyles() {
        super.bindStyles()
        
    }
}
