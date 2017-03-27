//
//  RepositoryIssuesDatasource.swift
//  GHClient
//
//  Created by Pi on 27/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class RepositoryIssuesDatasource: ValueCellDataSource {

  internal func set(issues: [Issue]) {
    self.set(values: issues, cellClass: RepositoryIssueTableViewCell.self, inSection: 0)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {
    switch (cell, value) {
    case let (cell as RepositoryIssueTableViewCell, item as Issue):
      cell.configureWith(value: item)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
  
}