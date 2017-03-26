//
//  IssueCommentEventPayload.swift
//  GHClient
//
//  Created by Pi on 22/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

extension IssueCommentEventPayload: EventPayloadTypeDisplay {
  internal var payloadView: UIView {
    let lab = GHCAttributedLabel()
    lab.numberOfLines = 0
    try? lab.set(markup: self.comment.body)
    lab.sizeToFit()
    return lab
  }
}
