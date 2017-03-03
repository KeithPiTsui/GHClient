//
//  MenuDataSource.swift
//  GHClient
//
//  Created by Pi on 03/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit




internal final class MenuDataSource: ValueCellDataSource {
    internal enum Section: Int {
        case personal
        case discovery
        case app
    }
    
    internal func load(personalItems: [MenuItem]) {
        self.set(values: personalItems,
                 cellClass: MenuGeneralCell.self,
                 inSection: Section.personal.rawValue)

    }
    
    internal func load(discoveryItems: [MenuItem]) {
        self.set(values: discoveryItems,
                 cellClass: MenuGeneralCell.self,
                 inSection: Section.discovery.rawValue)
    }
    
    internal func load(appItems: [MenuItem]) {
        self.set(values: appItems,
                 cellClass: MenuGeneralCell.self,
                 inSection: Section.app.rawValue)
    }
    
    override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as MenuGeneralCell, item as MenuItem):
            cell.configureWith(value: item)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
}
