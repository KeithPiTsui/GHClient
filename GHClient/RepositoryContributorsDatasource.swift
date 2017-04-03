//
//  RepositoryContributorsDatasource.swift
//  GHClient
//
//  Created by Pi on 27/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class RepositoryContributorsDatasource: ValueCellDataSource {

  internal func set(contributors: [UserLite]) {
    self.set(values: contributors.map(BasicTableViewValueCell.Style.contributor),
             cellClass: BasicTableViewValueCell.self,
             inSection: 0)
  }


  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {
    switch (cell, value) {
    case let (cell as BasicTableViewValueCell, item as BasicTableViewValueCell.Style):
      cell.configureWith(value: item)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
  
}
