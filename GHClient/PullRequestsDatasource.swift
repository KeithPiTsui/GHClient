//
//  PullRequestsDatasource.swift
//  GHClient
//
//  Created by Pi on 27/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class PullRequestsDatasource: ValueCellDataSource {

  internal func set(pullRequests: [PullRequest]) {
    self.set(values: pullRequests, cellClass: PullRequestTableViewCell.self, inSection: 0)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {
    switch (cell, value) {
    case let (cell as PullRequestTableViewCell, item as PullRequest):
      cell.configureWith(value: item)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
  
}
