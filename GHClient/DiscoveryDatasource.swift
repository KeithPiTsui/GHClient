//
//  DiscoveryDatasource.swift
//  GHClient
//
//  Created by Pi on 14/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import Foundation
import GHAPI

internal final class DiscoveryDatasource: ValueCellDataSource {

  internal func load(repos: [TrendingRepository]) {
    self.set(values: repos, cellClass: TrendingRepositoryTableViewCell.self, inSection: 0)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {
    switch (cell, value) {
    case let (cell as TrendingRepositoryTableViewCell, item as TrendingRepository):
      cell.configureWith(value: item)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
