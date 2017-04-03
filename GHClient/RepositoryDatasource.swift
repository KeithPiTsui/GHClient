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
      self.appendRow(value: BasicTableViewValueCell.Style.repoDescription(desc),
                     cellClass: BasicTableViewValueCell.self,
                     toSection: Section.Brief.rawValue)
    }

    self.appendRow(value: BasicTableViewValueCell.Style.readme(nil),
                   cellClass: BasicTableViewValueCell.self,
                   toSection: Section.Brief.rawValue)

    // Details
    self.appendRow(value: BasicTableViewValueCell.Style.forks(nil),
                   cellClass: BasicTableViewValueCell.self,
                   toSection: Section.DetailDiveIn.rawValue)
    self.appendRow(value: BasicTableViewValueCell.Style.releases(nil),
                   cellClass: BasicTableViewValueCell.self,
                   toSection: Section.DetailDiveIn.rawValue)
    self.appendRow(value: BasicTableViewValueCell.Style.activities(nil),
                   cellClass: BasicTableViewValueCell.self,
                   toSection: Section.DetailDiveIn.rawValue)
    self.appendRow(value: BasicTableViewValueCell.Style.contributors(nil),
                   cellClass: BasicTableViewValueCell.self,
                   toSection: Section.DetailDiveIn.rawValue)
    self.appendRow(value: BasicTableViewValueCell.Style.stargazers(nil),
                   cellClass: BasicTableViewValueCell.self,
                   toSection: Section.DetailDiveIn.rawValue)
    self.appendRow(value: BasicTableViewValueCell.Style.pullRequests(nil),
                   cellClass: BasicTableViewValueCell.self,
                   toSection: Section.DetailDiveIn.rawValue)
    self.appendRow(value: BasicTableViewValueCell.Style.issues(nil),
                   cellClass: BasicTableViewValueCell.self,
                   toSection: Section.DetailDiveIn.rawValue)
  }

  internal func set(readme: Readme?) {
    let r = self.valueSnapshot[Section.Brief.rawValue].count - 1
    self.set(value: BasicTableViewValueCell.Style.readme(readme),
             cellClass: BasicTableViewValueCell.self,
             inSection: Section.Brief.rawValue,
             row: r)
  }

  internal func set(forks: [Repository]?) {
    self.set(value: BasicTableViewValueCell.Style.forks(forks),
             cellClass: BasicTableViewValueCell.self,
             inSection: Section.DetailDiveIn.rawValue,
             row: Section.RepoPorperty.forks.rawValue)
  }

  internal func set(release: [Release]?) {
    self.set(value: BasicTableViewValueCell.Style.releases(release),
             cellClass: BasicTableViewValueCell.self,
             inSection: Section.DetailDiveIn.rawValue,
             row: Section.RepoPorperty.releases.rawValue)
  }

  internal func set(activities: [GHEvent]?) {
    self.set(value: BasicTableViewValueCell.Style.activities(activities),
             cellClass: BasicTableViewValueCell.self,
             inSection: Section.DetailDiveIn.rawValue,
             row: Section.RepoPorperty.activities.rawValue)
  }

  internal func set(contributors: [UserLite]?) {
    self.set(value: BasicTableViewValueCell.Style.contributors(contributors),
             cellClass: BasicTableViewValueCell.self,
             inSection: Section.DetailDiveIn.rawValue,
             row: Section.RepoPorperty.contributors.rawValue)
  }

  internal func set(stargazers: [UserLite]?) {
    self.set(value: BasicTableViewValueCell.Style.stargazers(stargazers),
             cellClass: BasicTableViewValueCell.self,
             inSection: Section.DetailDiveIn.rawValue,
             row: Section.RepoPorperty.stargazers.rawValue)
  }

  internal func set(pullRequests: [PullRequest]?) {
    self.set(value: BasicTableViewValueCell.Style.pullRequests(pullRequests),
             cellClass: BasicTableViewValueCell.self,
             inSection: Section.DetailDiveIn.rawValue,
             row: Section.RepoPorperty.pullRequests.rawValue)
  }

  internal func set(issues: [Issue]?) {
    self.set(value: BasicTableViewValueCell.Style.issues(issues),
             cellClass: BasicTableViewValueCell.self,
             inSection: Section.DetailDiveIn.rawValue,
             row: Section.RepoPorperty.issues.rawValue)
  }

  internal func set(branchLites: [BranchLite]) {
    self.clearValues(section: Section.Branchs.rawValue)
    branchLites.forEach { (branchLite) in
      self.appendRow(value: BasicTableViewValueCell.Style.branch(branchLite),
                     cellClass: BasicTableViewValueCell.self,
                     toSection: Section.Branchs.rawValue)
    }
  }

  internal func setCommit(on branchLites: [BranchLite]) {
    self.clearValues(section: Section.Commits.rawValue)
    branchLites.forEach { (branchLite) in
      self.appendRow(value: BasicTableViewValueCell.Style.commit(branchLite),
                     cellClass: BasicTableViewValueCell.self,
                     toSection: Section.Commits.rawValue)
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {

    switch (cell, value) {
    case let (cell as BasicTableViewValueCell, item as BasicTableViewValueCell.Style):
      cell.configureWith(value: item)
    case let (cell as RepositoryOwerTableViewCell, item as UserLite):
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



















