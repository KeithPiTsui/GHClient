//
//  UserProfileOrganizationDatasource.swift
//  GHClient
//
//  Created by Pi on 05/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

internal final class UserProfileOrganizationDatasource: ValueCellDataSource {

  internal func noOrganization(msg: String) {
    self.clearValues()
    self.set(values: [msg],
             cellClass: UserProfileNoOrganizationTableViewCell.self,
             inSection: 0)
  }

  internal func load(organizations: [UserProfileOrganizationTableViewCellConfig]) {
    self.set(values: organizations,
             cellClass: UserProfileOrganizationTableViewCell.self,
             inSection: 0)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {
    switch (cell, value) {
    case let (cell as UserProfileOrganizationTableViewCell, item as String):
      cell.configureWith(value: item)
    case let (cell as UserProfileNoOrganizationTableViewCell, item as String):
      cell.configureWith(value: item)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
