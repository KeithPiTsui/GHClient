//
//  MeSettingTableViewCell.swift
//  GHClient
//
//  Created by Pi on 27/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveCocoa
import Prelude_UIKit
import Ladder

internal final class MeSettingTableViewCell: UITableViewCell, ValueCell {

  func configureWith(value: ()) {
    self.textLabel?.text = "Settings"
  }
}
