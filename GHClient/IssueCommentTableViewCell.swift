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


  internal var bodyLabel: TTTAttributedLabel?

  override func awakeFromNib() {
    super.awakeFromNib()

    self.bodyLabel = TTTAttributedLabel(frame: CGRect.zero)
    if let v = self.bodyLabel {
      v.delegate = self
      v.font = UIFont.systemFont(ofSize: 22)
      v.numberOfLines = 0
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
    guard let str = try? Down(markdownString: value.body).toAttributedString() else { return }
    self.bodyLabel?.setText(str)

    let gt = Guitar(chord: .atUser)
    let ranges = gt.evaluate(string: str.string)
    let substr = ranges.map(str.string.substring(with:)).map{$0.trimLeft(byRemoving: 1)}.map{$0.trim()}
    let urls = substr.map{AppEnvironment.current.apiService.serverConfig.apiBaseUrl.appendingPathComponent("user/\($0)")}

    var dict: [String: URL] = [:]
    for (idx, str) in substr.enumerated() {
      dict[str] = urls[idx]
    }

    let desc: URLAttachedEventDescription = (str.string, dict)
    if desc.desc.isEmpty == false {
      let nsDesc = desc.desc as NSString
      desc.attachedURLs.forEach { (key, url) in
        _ = self.bodyLabel?.addLink(to: url, with: nsDesc.range(of: key))
      }
    }

  }
}

extension IssueCommentTableViewCell: TTTAttributedLabelDelegate {
  @objc func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
    guard
      let starter = self.superview,
      let vc = UIResponder.firstDescedant(TTTAttributedLabelDelegate.self)(starter),
      vc !== self
      else { return }
    vc.attributedLabel?(label, didSelectLinkWith: url)
  }
}




