//
//  RepositoryReadmeTableViewCell.swift
//  GHClient
//
//  Created by Pi on 26/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveCocoa
import Prelude
import Prelude_UIKit
import Ladder

internal final class RepositoryReadmeTableViewCell: UITableViewCell, ValueCell {

  func configureWith(value: (Void, Readme?)) {
    let value = second(value)
    let text = value == nil ? "No Readme" : "Readme"
    self.textLabel?.text = text
  }
}
