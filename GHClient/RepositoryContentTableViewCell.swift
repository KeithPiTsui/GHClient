//
//  RepositoryContentTableViewCell.swift
//  GHClient
//
//  Created by Pi on 21/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class RepositoryContentTableViewCell: UITableViewCell, ValueCell {
  func configureWith(value: Content) {
    self.textLabel?.text = value.name
    if value.type == "dir" {
      self.accessoryType = .disclosureIndicator
    } else if value.type == "file" {
      self.accessoryType = .detailDisclosureButton
    }
  }

}
