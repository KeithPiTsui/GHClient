//
//  IssueCommentTableViewCell.swift
//  GHClient
//
//  Created by Pi on 24/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import Down
import ReactiveCocoa
import Prelude_UIKit
import Ladder

internal final class IssueCommentTableViewCell: UITableViewCell, ValueCell {
  @IBOutlet weak var commentContainer: UIView!
  @IBOutlet weak var commentTimeLabel: UILabel!
  @IBOutlet weak var userNameBtn: UIButton!
  @IBOutlet weak var userAvatar: UIImageView!



  internal var bodyLabel = GHCAttributedLabel()

  override func awakeFromNib() {
    super.awakeFromNib()
      self.bodyLabel.detectors = [GuitarChord.atUser:"users", GuitarChord.url: ""]
      self.bodyLabel.numberOfLines = 0
      self.commentContainer.addSubview(self.bodyLabel)
      self.bodyLabel.fillupSuperView()
  }

  func configureWith(value: IssueComment) {
    self.userNameBtn.setTitle(value.user.login, for: .normal)
    self.commentTimeLabel.text = "\( Int(value.created_at.timeIntervalSinceNow / 60))"
    try? self.bodyLabel.set(markup: value.body)
  }
}















