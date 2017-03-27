//
//  RepositoryReleasesDatasource.swift
//  GHClient
//
//  Created by Pi on 27/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class RepositoryReleasesDatasource: ValueCellDataSource {

  internal func set(releases: [Release]) {
    self.set(values: releases, cellClass: RepositoryReleaseTableViewCell.self, inSection: 0)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {
    switch (cell, value) {
    case let (cell as RepositoryReleaseTableViewCell, item as Release):
      cell.configureWith(value: item)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
  
}
