//
//  RepositoryDatasource.swift
//  GHClient
//
//  Created by Pi on 11/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

fileprivate enum Section: Int {
  case Brief
  case DetailDiveIn
  case Branchs
  case Commits
  internal var name: String {
    return String(describing: self)
  }
}
extension Section: HashableEnumCaseIterating {}

internal final class RepositoryDatasource: ValueCellDataSource {

  fileprivate let titleSections: [Int] = [Section.Branchs.rawValue, Section.Commits.rawValue]

  internal func set(repo: Repository) {
    self.clearValues(section: Section.Brief.rawValue)
    self.clearValues(section: Section.DetailDiveIn.rawValue)
    let owner = repo.owner
    self.appendRow(value: owner, cellClass: RepositoryOwerTableViewCell.self, toSection: Section.Brief.rawValue)

    if let desc = repo.desc {
      self.appendRow(value: desc, cellClass: RepositoryDescriptionTableViewCell.self, toSection: Section.Brief.rawValue)
    }

    self.appendRow(value: ((), nil), cellClass: RepositoryReadmeTableViewCell.self, toSection: Section.Brief.rawValue)

    // Details
    self.appendRow(value: ((), nil), cellClass: RepositoryForksTableViewCell.self, toSection: Section.DetailDiveIn.rawValue)
    self.appendRow(value: ((), nil), cellClass: RepositoryReleasesTableViewCell.self, toSection: Section.DetailDiveIn.rawValue)
    self.appendRow(value: ((), nil), cellClass: RepositoryActivitiesTableViewCell.self, toSection: Section.DetailDiveIn.rawValue)
    self.appendRow(value: ((), nil), cellClass: RepositoryContributorsTableViewCell.self, toSection: Section.DetailDiveIn.rawValue)
    self.appendRow(value: ((), nil), cellClass: RepositoryStargazersTableViewCell.self, toSection: Section.DetailDiveIn.rawValue)
    self.appendRow(value: ((), nil), cellClass: RepositoryPullRequestsTableViewCell.self, toSection: Section.DetailDiveIn.rawValue)
    self.appendRow(value: ((), nil), cellClass: RepositoryIssuesTableViewCell.self, toSection: Section.DetailDiveIn.rawValue)

  }

  internal func set(readme: Readme) {
    let r = self.valueSnapshot[Section.Brief.rawValue].count - 1
    self.set(value: ((), readme), cellClass: RepositoryReadmeTableViewCell.self, inSection: Section.Brief.rawValue, row: r)
  }

  internal func set(forks: [Repository]?) {
    self.set(value: ((), forks), cellClass: RepositoryForksTableViewCell.self, inSection: Section.DetailDiveIn.rawValue, row: 0)
  }

  internal func set(release: [Release]?) {
    self.set(value: ((), release), cellClass: RepositoryReleasesTableViewCell.self, inSection: Section.DetailDiveIn.rawValue, row: 1)
  }

  internal func set(activities: [GHEvent]?) {
    self.set(value: ((), activities), cellClass: RepositoryActivitiesTableViewCell.self, inSection: Section.DetailDiveIn.rawValue, row: 2)
  }

  internal func set(contributors: [UserLite]?) {
    self.set(value: ((), contributors), cellClass: RepositoryContributorsTableViewCell.self, inSection: Section.DetailDiveIn.rawValue, row: 3)
  }

  internal func set(stargazers: [UserLite]?) {
    self.set(value: ((), stargazers), cellClass: RepositoryStargazersTableViewCell.self, inSection: Section.DetailDiveIn.rawValue, row: 4)
  }

  internal func set(pullRequests: [PullRequest]?) {
    self.set(value: ((), pullRequests), cellClass: RepositoryPullRequestsTableViewCell.self, inSection: Section.DetailDiveIn.rawValue, row: 5)
  }

  internal func set(issues: [Issue]?) {
    self.set(value: ((), issues), cellClass: RepositoryIssuesTableViewCell.self, inSection: Section.DetailDiveIn.rawValue, row: 6)
  }

  internal func set(branchLites: [BranchLite]) {
    self.clearValues(section: Section.Branchs.rawValue)
    branchLites.forEach { (branchLite) in
      self.appendRow(value: branchLite,
                     cellClass: RepositoryBranchTableViewCell.self,
                     toSection: Section.Branchs.rawValue)
    }
  }

  internal func setCommit(on branchLites: [BranchLite]) {
    self.clearValues(section: Section.Commits.rawValue)
    branchLites.forEach { (branchLite) in
      self.appendRow(value: branchLite,
                     cellClass: RepositoryCommitTableViewCell.self,
                     toSection: Section.Commits.rawValue)
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {
    switch (cell, value) {
    case let (cell as RepositoryOwerTableViewCell, item as UserLite):
      cell.configureWith(value: item)
    case let (cell as RepositoryDescriptionTableViewCell, item as String):
      cell.configureWith(value: item)
    case let (cell as RepositoryReadmeTableViewCell, item as (Void, Readme?)):
      cell.configureWith(value: item)
    case let (cell as RepositoryForksTableViewCell, item as (Void, [Repository]?)):
      cell.configureWith(value: item)
    case let (cell as RepositoryReleasesTableViewCell, item as (Void, [Release]?)):
      cell.configureWith(value: item)
    case let (cell as RepositoryActivitiesTableViewCell, item as (Void, [GHEvent]?)):
      cell.configureWith(value: item)
    case let (cell as RepositoryContributorsTableViewCell, item as (Void, [UserLite]?)):
      cell.configureWith(value: item)
    case let (cell as RepositoryStargazersTableViewCell, item as (Void, [UserLite]?)):
      cell.configureWith(value: item)
    case let (cell as RepositoryPullRequestsTableViewCell, item as (Void, [PullRequest]?)):
      cell.configureWith(value: item)
    case let (cell as RepositoryIssuesTableViewCell, item as (Void, [Issue]?)):
      cell.configureWith(value: item)
    case let (cell as RepositoryBranchTableViewCell, item as BranchLite):
      cell.configureWith(value: item)
    case let (cell as RepositoryCommitTableViewCell, item as BranchLite):
      cell.configureWith(value: item)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}

extension RepositoryDatasource {
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if self.titleSections.contains(section) {
      return Section(rawValue: section)?.name
    }
    return nil
  }
}
