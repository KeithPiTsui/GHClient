//
//  DetailTableViewValueCell.swift
//  GHClient
//
//  Created by Pi on 03/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveCocoa
import Prelude_UIKit
import Ladder

internal final class DetailTableViewValueCell: UITableViewCell, ValueCell {

  internal enum Style {
    case commit(Commit)
  }

  func configureWith(value: Style) {
    switch value {
    case .commit(let cmt):
      self.textLabel?.text = cmt.url.absoluteString
      self.detailTextLabel?.text = cmt.sha
    }
  }
}
