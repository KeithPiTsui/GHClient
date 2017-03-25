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

internal final class IssueBodyTableViewCell: UITableViewCell, ValueCell {

  @IBOutlet weak var bodyContainer: UIView!

  @IBOutlet weak var containerHeight: NSLayoutConstraint!

  internal var bodyLabel: GHCAttributedLabel?

  override func awakeFromNib() {
    super.awakeFromNib()

    self.bodyLabel = GHCAttributedLabel(frame: CGRect.zero)
    if let v = self.bodyLabel {
      v.font = UIFont.systemFont(ofSize: 14)
      v.numberOfLines = 0
      v.detectors = [GuitarChord.atUser:"users"]
      self.bodyContainer.addSubview(v)
      v.fillupSuperView()
    }
  }

  func configureWith(value: String) {
    try? self.bodyLabel?.set(markup: value)
  }
}








