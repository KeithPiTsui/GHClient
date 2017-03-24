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

  internal var markupCommentView: DownView?

  override func awakeFromNib() {
    super.awakeFromNib()
    self.markupCommentView = try? DownView(frame: CGRect.zero, markdownString: "")
    if let v = self.markupCommentView {
      v.translatesAutoresizingMaskIntoConstraints = false
      self.commentContainer.addSubview(v)
      v.topAnchor.constraint(equalTo: self.commentContainer.topAnchor).isActive = true
      v.bottomAnchor.constraint(equalTo: self.commentContainer.bottomAnchor).isActive = true
      v.leftAnchor.constraint(equalTo: self.commentContainer.leftAnchor).isActive = true
      v.rightAnchor.constraint(equalTo: self.commentContainer.rightAnchor).isActive = true
    }
  }

  func configureWith(value: IssueComment) {
    self.userNameBtn.setTitle(value.user.login, for: .normal)
    self.commentTimeLabel.text = "\( Int(value.created_at.timeIntervalSinceNow / 60))"
    try? self.markupCommentView?.update(markdownString: value.body)
  }


}
