//
//  CommitCommentTableViewCell.swift
//  GHClient
//
//  Created by Pi on 30/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveCocoa
import Prelude_UIKit
import Ladder

internal final class CommitCommentTableViewCell: UITableViewCell, ValueCell {

  @IBOutlet weak var commentLabel: GHCAttributedLabel!
  @IBOutlet weak var timestampLabel: UILabel!
  @IBOutlet weak var commenterName: UILabel!
  @IBOutlet weak var commenterIcon: UIImageView!

  func configureWith(value: CommitComment) {
    try? self.commentLabel.set(markup: value.body)
  }
}
