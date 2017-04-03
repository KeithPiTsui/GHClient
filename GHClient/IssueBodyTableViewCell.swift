//
//  IssueBodyTableViewCell.swift
//  GHClient
//
//  Created by Pi on 24/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveCocoa
import Prelude_UIKit
import Ladder
import Down
import WebKit

internal final class IssueBodyTableViewCell: UITableViewCell, ValueCell {

  internal var bodyLabel = GHCAttributedLabel()

  override func awakeFromNib() {
    super.awakeFromNib()
    self.contentView.addSubview(self.bodyLabel)
    self.bodyLabel.detectors = [GuitarChord.atUser:"users", GuitarChord.url: ""]
    self.bodyLabel.numberOfLines = 0
    self.bodyLabel.fillupSuperView()
  }

  func configureWith(value: String) {
    try? self.bodyLabel.set(markup: value)
  }
}






