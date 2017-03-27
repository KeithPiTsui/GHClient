//
//  RepositoryDatasource.swift
//  GHClient
//
//  Created by Pi on 11/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI




internal final class RepositoryDatasource: ValueCellDataSource {

  internal enum Section: Int {
    case Brief
    case DetailDiveIn
    case Branchs
    case Commits
    internal var name: String {
      return String(describing: self)
    }

    internal enum RepoPorperty: Int {
      case forks
      case releases
      case activities
      case contributors
      case stargazers
      case pullRequests
      case issues
    }
  }

  fileprivate let titleSections: [Int] = [Section.Branchs.rawValue, Section.Commits.rawValue]

  internal func set(repo: Repository) {
    self.clearValues(section: Section.Brief.rawValue)
    self.clearValues(section: Section.DetailDiveIn.rawValue)
    let owner = repo.owner
    self.appendRow(value: owner, cellClass: RepositoryOwerTableViewCell.self, toSection: Section.Brief.rawValue)

    if let desc = repo.desc {
      self.appendRow(value: desc, cellClass: RepositoryDescriptionTableViewCell.self, toSection: Section.Brief.rawValue)
    }

    self.appendRow(value: nil, cellClass: RepositoryReadmeTableViewCell.self, toSection: Section.Brief.rawValue)

    // Details
    self.appendRow(value: nil, cellClass: RepositoryForksTableViewCell.self, toSection: Section.DetailDiveIn.rawValue)
    self.appendRow(value: nil, cellClass: RepositoryReleasesTableViewCell.self, toSection: Section.DetailDiveIn.rawValue)
    self.appendRow(value: nil, cellClass: RepositoryActivitiesTableViewCell.self, toSection: Section.DetailDiveIn.rawValue)
    self.appendRow(value: nil, cellClass: RepositoryContributorsTableViewCell.self, toSection: Section.DetailDiveIn.rawValue)
    self.appendRow(value: nil, cellClass: RepositoryStargazersTableViewCell.self, toSection: Section.DetailDiveIn.rawValue)
    self.appendRow(value: nil, cellClass: RepositoryPullRequestsTableViewCell.self, toSection: Section.DetailDiveIn.rawValue)
    self.appendRow(value: nil, cellClass: RepositoryIssuesTableViewCell.self, toSection: Section.DetailDiveIn.rawValue)
  }

  internal func set(readme: Readme?) {
    let r = self.valueSnapshot[Section.Brief.rawValue].count - 1
    self.set(value: readme, cellClass: RepositoryReadmeTableViewCell.self, inSection: Section.Brief.rawValue, row: r)
  }

  internal func set(forks: [Repository]?) {
    self.set(value: forks,
             cellClass: RepositoryForksTableViewCell.self,
             inSection: Section.DetailDiveIn.rawValue,
             row: Section.RepoPorperty.forks.rawValue)
  }

  internal func set(release: [Release]?) {
    self.set(value: release, 
             cellClass: RepositoryReleasesTableViewCell.self,
             inSection: Section.DetailDiveIn.rawValue,
             row: Section.RepoPorperty.releases.rawValue)
  }

  internal func set(activities: [GHEvent]?) {
    self.set(value: activities,
             cellClass: RepositoryActivitiesTableViewCell.self,
             inSection: Section.DetailDiveIn.rawValue,
             row: Section.RepoPorperty.activities.rawValue)
  }

  internal func set(contributors: [UserLite]?) {
    self.set(value: contributors,
             cellClass: RepositoryContributorsTableViewCell.self,
             inSection: Section.DetailDiveIn.rawValue,
             row: Section.RepoPorperty.contributors.rawValue)
  }

  internal func set(stargazers: [UserLite]?) {
    self.set(value: stargazers,
             cellClass: RepositoryStargazersTableViewCell.self,
             inSection: Section.DetailDiveIn.rawValue,
             row: Section.RepoPorperty.stargazers.rawValue)
  }

  internal func set(pullRequests: [PullRequest]?) {
    self.set(value: pullRequests,
             cellClass: RepositoryPullRequestsTableViewCell.self,
             inSection: Section.DetailDiveIn.rawValue,
             row: Section.RepoPorperty.pullRequests.rawValue)
  }

  internal func set(issues: [Issue]?) {
    self.set(value: issues,
             cellClass: RepositoryIssuesTableViewCell.self,
             inSection: Section.DetailDiveIn.rawValue,
             row: Section.RepoPorperty.issues.rawValue)
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
    case let (cell as RepositoryReadmeTableViewCell, value) where (unwrap(value: value) as (Readme?, Bool)).1:
      cell.configureWith(value: (unwrap(value: value) as (Readme?, Bool)).0)
    case let (cell as RepositoryForksTableViewCell, value) where (unwrap(value: value) as ([Repository]?, Bool)).1:
      cell.configureWith(value: (unwrap(value: value) as ([Repository]?, Bool)).0)
    case let (cell as RepositoryReleasesTableViewCell, value) where (unwrap(value: value) as ([Release]?, Bool)).1:
      cell.configureWith(value: (unwrap(value: value) as ([Release]?, Bool)).0)
    case let (cell as RepositoryActivitiesTableViewCell, value) where (unwrap(value: value) as ([GHEvent]?, Bool)).1:
      cell.configureWith(value: (unwrap(value: value) as ([GHEvent]?, Bool)).0)
    case let (cell as RepositoryContributorsTableViewCell, value) where (unwrap(value: value) as ([UserLite]?, Bool)).1:
      cell.configureWith(value: (unwrap(value: value) as ([UserLite]?, Bool)).0)
    case let (cell as RepositoryStargazersTableViewCell, value) where (unwrap(value: value) as ([UserLite]?, Bool)).1:
      cell.configureWith(value: (unwrap(value: value) as ([UserLite]?, Bool)).0)
    case let (cell as RepositoryPullRequestsTableViewCell, value) where (unwrap(value: value) as ([PullRequest]?, Bool)).1:
      cell.configureWith(value: (unwrap(value: value) as ([PullRequest]?, Bool)).0)
    case let (cell as RepositoryIssuesTableViewCell, value) where (unwrap(value: value) as ([Issue]?, Bool)).1:
      cell.configureWith(value: (unwrap(value: value) as ([Issue]?, Bool)).0)
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


extension RepositoryDatasource.Section: HashableEnumCaseIterating {}



















