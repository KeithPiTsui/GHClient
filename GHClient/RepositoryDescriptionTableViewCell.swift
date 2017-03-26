//
//  RepositoryDescriptionTableViewCell.swift
//  GHClient
//
//  Created by Pi on 26/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveCocoa
import Prelude_UIKit
import Ladder

internal final class RepositoryDescriptionTableViewCell: UITableViewCell, ValueCell {

  internal var bodyLabel = GHCAttributedLabel(frame: CGRect.zero)

  override func awakeFromNib() {
    super.awakeFromNib()
    self.bodyLabel.font = UIFont.systemFont(ofSize: 18)
    self.bodyLabel.lineBreakMode = .byWordWrapping
    self.bodyLabel.numberOfLines = 0
    self.bodyLabel.detectors = [GuitarChord.atUser:"users"]
    self.contentView.addSubview(self.bodyLabel)
    self.bodyLabel.fillupSuperView()
  }

  func configureWith(value: String) {
    try? self.bodyLabel.set(markup: value)
  }
}
