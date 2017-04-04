//
//  PushEventExtension.swift
//  GHClient
//
//  Created by Pi on 22/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

extension PushEventPayload: EventPayloadTypeDisplay {
  internal var payloadView: UIView {
    let str = self.commits.reduce("", { (str, commit) -> String in
      let sha = commit.sha?.last(8) ?? ""
      let msg  = commit.message
      return str + "\n" + sha + " " + msg
    }).trimmingCharacters(in: .whitespacesAndNewlines)
    let lab = UILabel(frame: UIScreen.main.bounds)
    lab.numberOfLines = 5
    lab.font = UIFont.systemFont(ofSize: 12)
    lab.text = str
    lab.sizeToFit()
    return lab
  }
}
