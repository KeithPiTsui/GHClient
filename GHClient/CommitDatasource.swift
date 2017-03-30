//
//  CommitDatasource.swift
//  GHClient
//
//  Created by Pi on 30/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class CommitDatasource: ValueCellDataSource {
  internal enum Section: Int {
    case commitDescription
    case changes
    case comments
  }

  internal func set(commitDesc: String) {

  }

  internal func set(commitComments: [CommitComment]) {
    
  }

  internal func setCommitChanges(files: [Commit.CFile],
                                 with changesTypes: [CommitChangesTableViewCell.CommitChangesType]) {
    self.clearValues(section: Section.changes.rawValue)
    for (idx, changesType) in changesTypes.enumerated() {
      self.appendRow(value: (files, changesType), cellClass: CommitChangesTableViewCell.self, toSection: idx)
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {
    switch (cell, value) {
    case let (cell as CommitChangesTableViewCell, item as CommitChangesTableViewCell.CommitChangesConfig):
      cell.configureWith(value: item)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
  
}
