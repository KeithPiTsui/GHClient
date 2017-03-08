//
//  MenuGeneralCell.swift
//  GHClient
//
//  Created by Pi on 03/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit


internal final class MenuGeneralCell: UITableViewCell, ValueCell {

    internal var section: Int = 0
    internal var row: Int = 0
    internal weak var dataSource: ValueCellDataSource? = nil
    
    
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemIconView: UIImageView!

    func configureWith(value: MenuItem) {
        self.itemIconView.image = value.itemIcon
        self.itemName.text = value.itemName
    }
    
    override func bindViewModel() {
        super.bindViewModel()
    }
 
    override func bindStyles() {
        super.bindStyles()
        
    }
}
