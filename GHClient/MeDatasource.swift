//
//  MeDatasource.swift
//  GHClient
//
//  Created by Pi on 27/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class MeDatasource: ValueCellDataSource {

  internal enum Section: Int {
    case Brief
    case Repositories
    case Gists
    case Settings
    case Logout

    internal enum Repository: Int {
      case personal
      case watched
      case starred
      case issues
      case pullRequests
    }
  }

  internal func set(userBrief: User) {
    self.set(values: [userBrief], cellClass: MeUserBriefTableViewCell.self, inSection: Section.Brief.rawValue)
    self.setSettings()
    self.setLogout()
    
    self.clearValues(section: Section.Repositories.rawValue)
    self.clearValues(section: Section.Gists.rawValue)

    self.appendRow(value: nil,
                   cellClass: MePersonalRepositoriesTableViewCell.self,
                   toSection: Section.Repositories.rawValue)
    self.appendRow(value: nil,
                   cellClass: MeWatchedRepositoriesTableViewCell.self,
                   toSection: Section.Repositories.rawValue)
    self.appendRow(value: nil,
                   cellClass: MeStarredRepositoriesTableViewCell.self,
                   toSection: Section.Repositories.rawValue)
    self.appendRow(value: nil,
                   cellClass: MeIssuesTableViewCell.self,
                   toSection: Section.Repositories.rawValue)
    self.appendRow(value: nil,
                   cellClass: MePullRequestsTableViewCell.self,
                   toSection: Section.Repositories.rawValue)

//    self.appendRow(value: nil,
//                   cellClass: MePersonalGistsTableViewCell.self,
//                   toSection: Section.Gists.rawValue)
//    self.appendRow(value: nil,
//                   cellClass: MeStarredGistsTableViewCell.self,
//                   toSection: Section.Gists.rawValue)

  }


  internal func set(personalRepos: [Repository]?) {
    self.set(value: personalRepos,
             cellClass: MePersonalRepositoriesTableViewCell.self,
             inSection: Section.Repositories.rawValue,
             row: Section.Repository.personal.rawValue)
  }

  internal func set(watchedRepos: [Repository]?) {
    self.set(value: watchedRepos,
             cellClass: MeWatchedRepositoriesTableViewCell.self,
             inSection: Section.Repositories.rawValue,
             row: Section.Repository.watched.rawValue)
  }

  internal func set(starredRepos: [Repository]?) {
    self.set(value: starredRepos,
             cellClass: MeStarredRepositoriesTableViewCell.self,
             inSection: Section.Repositories.rawValue,
             row: Section.Repository.starred.rawValue)
  }

  internal func set(issues: [Issue]?) {
    self.set(value: issues,
             cellClass: MeIssuesTableViewCell.self,
             inSection: Section.Repositories.rawValue,
             row: Section.Repository.issues.rawValue)
  }

  internal func set(pullRequests: [PullRequest]?) {
    self.set(value: pullRequests,
             cellClass: MePullRequestsTableViewCell.self,
             inSection: Section.Repositories.rawValue,
             row: Section.Repository.pullRequests.rawValue)
  }

  internal func setSettings() {
    self.set(values: [()], cellClass: MeSettingTableViewCell.self, inSection: Section.Settings.rawValue)
  }

  internal func setLogout() {
    self.set(values: [()], cellClass: MeLogoutTableViewCell.self, inSection: Section.Logout.rawValue)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {
    switch (cell, value) {
    case let (cell as MeLogoutTableViewCell, item as ()):
      cell.configureWith(value: item)
    case let (cell as MeSettingTableViewCell, item as ()):
      cell.configureWith(value: item)
    case let (cell as MeUserBriefTableViewCell, item as User):
      cell.configureWith(value: item)
    case let (cell as MePersonalRepositoriesTableViewCell, value) where (unwrap(value: value) as ([Repository]?, Bool)).1:
      cell.configureWith(value: (unwrap(value: value) as ([Repository]?, Bool)).0)
    case let (cell as MeWatchedRepositoriesTableViewCell, value) where (unwrap(value: value) as ([Repository]?, Bool)).1:
      cell.configureWith(value: (unwrap(value: value) as ([Repository]?, Bool)).0)
    case let (cell as MeStarredRepositoriesTableViewCell, value) where (unwrap(value: value) as ([Repository]?, Bool)).1:
      cell.configureWith(value: (unwrap(value: value) as ([Repository]?, Bool)).0)
    case let (cell as MeIssuesTableViewCell, value) where (unwrap(value: value) as ([Issue]?, Bool)).1:
      cell.configureWith(value: (unwrap(value: value) as ([Issue]?, Bool)).0)
    case let (cell as MePullRequestsTableViewCell, value) where (unwrap(value: value) as ([PullRequest]?, Bool)).1:
      cell.configureWith(value: (unwrap(value: value) as ([PullRequest]?, Bool)).0)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
  
}


