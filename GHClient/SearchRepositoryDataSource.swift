//
//  SearchRepositoryDataSource.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class SearchRepositoryDataSource: ValueCellDataSource {
    internal func load(repositories: [Repository]) {
        self.set(values: repositories,
                 cellClass: SearchRepositoryTableViewCell.self,
                 inSection: 0)
        
    }
    
    override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {
        switch (cell, value) {
        case let (cell as SearchRepositoryTableViewCell, item as Repository):
            cell.configureWith(value: item)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
}
