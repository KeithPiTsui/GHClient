//
//  ChangedFilesDatasource.swift
//  GHClient
//
//  Created by Pi on 10/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class ChangedFilesDatasource: ValueCellDataSource {

  internal func set(files: [Commit.CFile]) {
    self.set(values: files, cellClass: ChangedFileTableViewCell.self, inSection: 0)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {
    switch (cell, value) {
    case let (cell as ChangedFileTableViewCell, item as Commit.CFile):
      cell.configureWith(value: item)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
  
}
