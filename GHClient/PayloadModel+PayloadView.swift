//
//  PayloadModel+PayloadView.swift
//  GHClient
//
//  Created by Pi on 09/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

extension PullRequestEventPayload: EventPayloadTypeDisplay {
  internal var payloadView: UIView {
    let lab = UILabel()
    lab.numberOfLines = 5
    lab.text = self.pull_request.title
    lab.sizeToFit()
    return lab
  }
}

extension IssueEventPayload: EventPayloadTypeDisplay {
  internal var payloadView: UIView {
    let lab = UILabel()
    lab.numberOfLines = 5
    lab.text = self.issue.title
    lab.sizeToFit()
    return lab
  }
}

extension PullRequestReviewCommentEventPayload: EventPayloadTypeDisplay {
  internal var payloadView: UIView {
    let lab = GHCAttributedLabel()
    lab.numberOfLines = 5
    try? lab.set(markup: self.comment.body)
    lab.sizeToFit()
    return lab
  }
}

extension CreateEventPayload: EventPayloadTypeDisplay {
  internal var payloadView: UIView {
    let lab = UILabel()
    lab.numberOfLines = 5
    lab.text = self.desc
    lab.sizeToFit()
    return lab
  }
}

extension ReleaseEventPayload: EventPayloadTypeDisplay {
  internal var payloadView: UIView {
    let lab = UILabel()
    lab.numberOfLines = 5
    lab.text = self.release.body
    lab.sizeToFit()
    return lab
  }
}

extension CommitCommentEventPayload: EventPayloadTypeDisplay {
  internal var payloadView: UIView {
    let lab = GHCAttributedLabel()
    lab.numberOfLines = 5
    try? lab.set(markup: self.comment.body)
    lab.sizeToFit()
    return lab
  }
}

extension GollumEventPayload: EventPayloadTypeDisplay {
  internal var payloadView: UIView {
    let lab = GHCAttributedLabel()
    lab.numberOfLines = 5

    var urls = [String: URL]()
    self.pages
      .map { ($0.page_name, $0.html_url) }
      .forEach { urls[$0] = $1 }
    let desc = self.pages
      .map{$0.page_name}
      .reduce("") {"\($0) \($1) \n" }
      .trim()
    lab.set((desc, urls))

    lab.sizeToFit()
    return lab
  }
}

























