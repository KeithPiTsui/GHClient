//
//  UserProfileEventTableViewCell.swift
//  GHClient
//
//  Created by Pi on 05/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

public typealias UserProfileEventTableViewCellConfig = (icon: UIImage, name: String)

public final class UserProfileEventTableViewCell: UITableViewCell, ValueCell {
  public func configureWith(value: UserProfileEventTableViewCellConfig) {
    self.imageView?.image = value.icon
    self.textLabel?.text = value.name
  }
}
