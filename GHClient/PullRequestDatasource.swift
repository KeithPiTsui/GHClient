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

  internal func load(issue: Issue) {
    let section = PullRequestDatasourceSection.details.rawValue
    self.clearValues(section: section)
    self.appendRow(value: issue, cellClass: IssueTableViewCell.self, toSection: section)
    self.appendRow(value: issue.labels, cellClass: IssueLabelTableViewCell.self, toSection: section)
    self.appendRow(value: issue.body, cellClass: IssueBodyTableViewCell.self, toSection: section)

  }

  internal func loadd(issueComments: [IssueComment]) {
    let section = PullRequestDatasourceSection.comments.rawValue
    self.set(values: issueComments, cellClass: IssueCommentTableViewCell.self, inSection: section)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {
    switch (cell, value) {
    case let (cell as IssueTableViewCell, item as Issue):
      cell.configureWith(value: item)
    case let (cell as IssueLabelTableViewCell, item as [Issue.ILabel]):
      cell.configureWith(value: item)
    case let (cell as IssueBodyTableViewCell, item as String):
      cell.configureWith(value: item)
    case let (cell as IssueCommentTableViewCell, item as IssueComment):
      cell.configureWith(value: item)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
  
}
