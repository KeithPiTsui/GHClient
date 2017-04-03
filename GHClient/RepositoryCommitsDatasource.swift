//
//  RepositoryCommitsDatasource.swift
//  GHClient
//
//  Created by Pi on 27/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class RepositoryCommitsDatasource: ValueCellDataSource {

  internal func commit(of indexPath: IndexPath) -> Commit? {
    guard let value = self[indexPath] as? DetailTableViewValueCell.Style else { return nil }

    if case let .commit(cmt) = value {
      return cmt
    }

    return nil
  }

  internal func set(commits: [Commit]) {
    self.set(values: commits.map(DetailTableViewValueCell.Style.commit),
             cellClass: DetailTableViewValueCell.self,
             inSection: 0)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {
    switch (cell, value) {
    case let (cell as DetailTableViewValueCell, item as DetailTableViewValueCell.Style):
      cell.configureWith(value: item)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
  
}
