//
//  RepositoryContentDatasource.swift
//  GHClient
//
//  Created by Pi on 21/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class RepositoryContentDatasource: ValueCellDataSource {
  internal func load(contents: [Content]) {
    self.set(values: contents,
             cellClass: RepositoryContentTableViewCell.self,
             inSection: 0)

  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {
    switch (cell, value) {
    case let (cell as RepositoryContentTableViewCell, item as Content):
      cell.configureWith(value: item)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
