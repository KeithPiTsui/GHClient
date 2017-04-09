//
//  PayloadModel+PayloadView.swift
//  GHClient
//
//  Created by Pi on 09/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

extension ForkEventPayload: EventPayloadTypeDisplay {
  internal var payloadView: UIView {
    let lab = UILabel()
    lab.numberOfLines = 5
    lab.text = self.forkee.desc ?? ""
    lab.sizeToFit()
    return  lab
  }
}

extension IssueCommentEventPayload: EventPayloadTypeDisplay {
  internal var payloadView: UIView {
    let lab = GHCAttributedLabel()
    lab.numberOfLines = 5
    try? lab.set(markup: self.comment.body)
    lab.sizeToFit()
    return lab
  }
}

extension PushEventPayload: EventPayloadTypeDisplay {
  internal var payloadView: UIView {
    let str = self.commits.reduce("", { (str, commit) -> String in
      let sha = commit.sha?.last(8) ?? ""
      let msg  = commit.message
      return str + "\n" + sha + " " + msg
    }).trim()
    let lab = UILabel()
    lab.numberOfLines = 5
    lab.font = UIFont.systemFont(ofSize: 12)
    lab.text = str
    lab.sizeToFit()
    return lab
  }
}

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

extension ProjectCardEventPayload: EventPayloadTypeDisplay {
  internal var payloadView: UIView {
    let lab = UILabel()
    lab.numberOfLines = 5
    lab.text = self.project_card.note
    lab.sizeToFit()
    return lab
  }
}

extension PullRequestReviewEventPayload: EventPayloadTypeDisplay {
  internal var payloadView: UIView {
    let lab = GHCAttributedLabel()
    lab.numberOfLines = 5
    try? lab.set(markup: self.review.body)
    lab.sizeToFit()
    return lab
  }
}

extension RepositoryEventPayload: EventPayloadTypeDisplay {
  internal var payloadView: UIView {
    let lab = UILabel()
    lab.numberOfLines = 5
    lab.text = self.repository.desc
    lab.sizeToFit()
    return lab
  }
}





















