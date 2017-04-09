//
//  PullRequestTableViewCell.swift
//  GHClient
//
//  Created by Pi on 09/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveCocoa
import Prelude_UIKit
import Ladder
import AlamofireImage

internal final class PullRequestTableViewCell: UITableViewCell, ValueCell {

  @IBOutlet weak var userAvatar: UIImageView!
  @IBOutlet weak var pullRequestDesc: GHCAttributedLabel!

  func configureWith(value: PullRequest) {
    userAvatar.af_cancelImageRequest()
    userAvatar.ksr_setImageWithURL(value.user.avatar.url)

    var urls = [String: URL]()
    let baseRepo = value.base.repo.full_name
    let baseRepoURL = value.base.repo.urls.url.appendingPathComponent(URLTargetStrings.repository.rawValue)
    urls[baseRepo] = baseRepoURL

    let baseRef = value.base.label
    let baseRefURL = AppEnvironment.current.apiService.contentURL(of: value.base.repo, ref: value.base.ref)
    urls[baseRef] = baseRefURL.appendingPathComponent(URLTargetStrings.content.rawValue)

    let headRef = value.head.label
    let headRefURL = AppEnvironment.current.apiService.contentURL(of: value.head.repo, ref: value.head.ref)
    urls[headRef] = headRefURL.appendingPathComponent(URLTargetStrings.content.rawValue)

    let user = value.user.login
    let userURL = value.user.urls.url
    urls[user] = userURL.appendingPathComponent(URLTargetStrings.user.rawValue)

    let createdTime = value.dates.created_at

    var desc = "\(user) opened this pull request for \(baseRef) at \(createdTime)"
    if value.mergeable == true {
      desc += "\nMerges \(value.numbers.commits ?? 0) commits into \(baseRef) from \(headRef)"
    }

    self.pullRequestDesc.set((desc, urls))
  }
}
