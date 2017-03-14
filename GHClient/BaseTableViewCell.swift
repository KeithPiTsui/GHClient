//
//  BaseTableViewCell.swift
//  GHClient
//
//  Created by Pi on 14/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell , ValueCell {
    
    internal var section: Int = 0
    internal var row: Int = 0
    internal weak var dataSource: ValueCellDataSource? = nil
    
    func configureWith(value: Any) {
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
