//
//  UserProfileOrganizationTableViewCell.swift
//  GHClient
//
//  Created by Pi on 05/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

internal typealias UserProfileOrganizationTableViewCellConfig = String

internal final class UserProfileOrganizationTableViewCell: UITableViewCell, ValueCell {

  internal var section: Int = 0
  internal var row: Int = 0
  internal weak var dataSource: ValueCellDataSource? = nil


  internal func configureWith(value: UserProfileOrganizationTableViewCellConfig) {
    self.textLabel?.text = value
  }
}

internal final class UserProfileNoOrganizationTableViewCell: UITableViewCell, ValueCell {

  internal var section: Int = 0
  internal var row: Int = 0
  internal var dataSource: ValueCellDataSource? = nil

  internal func configureWith(value: String) {
    self.textLabel?.text = value
  }
}
