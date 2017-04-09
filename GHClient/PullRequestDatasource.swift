//
//  PullRequestDatasource.swift
//  GHClient
//
//  Created by Pi on 03/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal enum PullRequestDatasourceSection: Int {
  case details
  case changes
  case comments
}


internal final class PullRequestDatasource: ValueCellDataSource {

  internal func set(pullRequest: PullRequest) {
    self.set(values: [pullRequest],
             cellClass: PullRequestTableViewCell.self,
             inSection: PullRequestDatasourceSection.details.rawValue)
    let changesSection = PullRequestDatasourceSection.changes.rawValue
    self.clearValues(section: changesSection)
    self.appendRow(value: BasicTableViewValueCell.Style.commits,
                   cellClass: BasicTableViewValueCell.self,
                   toSection: changesSection)
    self.appendRow(value: BasicTableViewValueCell.Style.files,
                   cellClass: BasicTableViewValueCell.self,
                   toSection: changesSection)
    self.appendRow(value: BasicTableViewValueCell.Style.diff,
                   cellClass: BasicTableViewValueCell.self,
                   toSection: changesSection)
  }


  internal func set(comments: [IssueComment]) {
    let section = PullRequestDatasourceSection.comments.rawValue
    self.set(values: comments, cellClass: IssueCommentTableViewCell.self, inSection: section)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {
    switch (cell, value) {
    case let (cell as PullRequestTableViewCell, item as PullRequest):
      cell.configureWith(value: item)
    case let (cell as BasicTableViewValueCell, item as BasicTableViewValueCell.Style):
      cell.configureWith(value: item)
    case let (cell as IssueCommentTableViewCell, item as IssueComment):
      cell.configureWith(value: item)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
  
}
