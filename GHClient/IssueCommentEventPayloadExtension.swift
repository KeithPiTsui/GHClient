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
    let lab = UILabel(frame: UIScreen.main.bounds)
    lab.numberOfLines = 0
    lab.text = self.comment.body
    lab.sizeToFit()
    return lab
  }
}
