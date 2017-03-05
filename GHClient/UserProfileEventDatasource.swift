//
//  UserProfileEventDatasource.swift
//  GHClient
//
//  Created by Pi on 05/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

internal final class UserProfileEventDatasource: ValueCellDataSource {
    
    internal func load(events: [UserProfileEventTableViewCellConfig]) {
        self.set(values: events,
                 cellClass: UserProfileEventTableViewCell.self,
                 inSection: 0)
    }
    
    
    override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as UserProfileEventTableViewCell, item as UserProfileEventTableViewCellConfig):
            cell.configureWith(value: item)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
}
