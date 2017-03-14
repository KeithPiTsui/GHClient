//
//  ActivitiesWatchingDatasource.swift
//  GHClient
//
//  Created by Pi on 13/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class ActivitesWatchingDatasource: ValueCellDataSource {
    
    internal func load(watchings: [GHEvent]) {
        self.set(values: watchings, cellClass: BaseTableViewCell.self, inSection: 0)
    }
    
    
    override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {
        switch (cell, value) {
        case let (cell as BaseTableViewCell, item as GHEvent):
            cell.textLabel?.text = item.type.rawValue
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
}
