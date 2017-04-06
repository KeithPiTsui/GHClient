//
//  EventTableViewCell.swift
//  GHClient
//
//  Created by Pi on 15/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveCocoa
import Prelude_UIKit
import Ladder
import AlamofireImage

internal final class EventTableViewCell: UITableViewCell , ValueCell {

  @IBOutlet weak var timestamp: UILabel!
  @IBOutlet weak var eventIcon: UIImageView!
  @IBOutlet weak var actorAvatar: UIImageView!
  @IBOutlet weak var eventDesc: TTTAttributedLabel!
  @IBOutlet weak var payloadDisplay: UIView!


  fileprivate var displayConstraints: [NSLayoutConstraint] = []

  func configureWith(value: GHEvent) {

    self.actorAvatar.af_cancelImageRequest()
    self.actorAvatar.ksr_setImageWithURL(value.actor.avatar_url)

    self.timestamp.text = value.created_at.ISO8601DateRepresentation
    if let payload = value.payload {
      self.installPayloadDisplay(with: payload)
    } else {
      self.uninstallPayloadDisplay()
    }
    let desc = value.summary
    if desc.desc.isEmpty == false {
      self.eventDesc.text = desc.desc
      let nsDesc = desc.desc as NSString
      desc.attachedURLs.forEach { (key, url) in
        self.eventDesc.addLink(to: url, with: nsDesc.range(of: key))
      }
    } else {
      self.eventDesc.text = value.id
    }
  }

  fileprivate func uninstallPayloadDisplay() {
    /// Deactive constraints of previous view
    NSLayoutConstraint.deactivate(displayConstraints)
    /// Remove previous view
    self.payloadDisplay.subviews.forEach {$0.removeFromSuperview()}
  }

  fileprivate func installPayloadDisplay(with payload: EventPayloadType) {
    self.uninstallPayloadDisplay()
    /// ask for a new view of current payload
    let v = payload.payloadView
    /// add as subview
    self.payloadDisplay.addSubview(v)
    v.translatesAutoresizingMaskIntoConstraints = false
    /// setup constraints for payload view
    displayConstraints =
      [v.topAnchor.constraint(equalTo: self.payloadDisplay.topAnchor),
       v.bottomAnchor.constraint(equalTo: self.payloadDisplay.bottomAnchor),
       v.leftAnchor.constraint(equalTo: self.payloadDisplay.leftAnchor),
       v.rightAnchor.constraint(equalTo: self.payloadDisplay.rightAnchor)]
    /// active constraints
    NSLayoutConstraint.activate(displayConstraints)
  }
}





























