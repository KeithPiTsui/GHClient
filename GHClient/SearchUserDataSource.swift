//
//  SearchUserDataSource.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class SearchUserDataSource: ValueCellDataSource {
    
    internal func load(users: [User]) {
        self.set(values: users,
                 cellClass: SearchUserTableViewCell.self,
                 inSection: 0)
        
    }
    
    override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as SearchUserTableViewCell, item as User):
            cell.configureWith(value: item)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
}
