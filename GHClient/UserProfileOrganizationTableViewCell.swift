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
  internal func configureWith(value: UserProfileOrganizationTableViewCellConfig) {
    self.textLabel?.text = value
  }
}

internal final class UserProfileNoOrganizationTableViewCell: UITableViewCell, ValueCell {
  internal func configureWith(value: String) {
    self.textLabel?.text = value
  }
}
