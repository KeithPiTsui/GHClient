//
//  UserProfileOrganizationTableViewCell.swift
//  GHClient
//
//  Created by Pi on 05/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

public typealias UserProfileOrganizationTableViewCellConfig = String

public final class UserProfileOrganizationTableViewCell: UITableViewCell, ValueCell {
  public func configureWith(value: UserProfileOrganizationTableViewCellConfig) {
    self.textLabel?.text = value
  }
}

public final class UserProfileNoOrganizationTableViewCell: UITableViewCell, ValueCell {
  public func configureWith(value: String) {
    self.textLabel?.text = value
  }
}
