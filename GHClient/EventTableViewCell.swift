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

internal final class EventTableViewCell: UITableViewCell , ValueCell {

  internal var section: Int = 0
  internal var row: Int = 0
  internal weak var dataSource: ValueCellDataSource? = nil
  @IBOutlet weak var timestamp: UILabel!
  @IBOutlet weak var eventIcon: UIImageView!
  @IBOutlet weak var actorAvatar: UIImageView!
  @IBOutlet weak var eventDesc: TTTAttributedLabel!
  @IBOutlet weak var payloadDisplay: UIView!


  fileprivate var displayConstraints: [NSLayoutConstraint] = []

  func configureWith(value: GHEvent) {
    self.timestamp.text = value.created_at.ISO8601DateRepresentation
    if let payload = value.payload {
      self.installPayloadDisplay(with: payload)
    } else {
      self.uninstallPayloadDisplay()
    }
  }

  fileprivate func uninstallPayloadDisplay() {
    /// Deactive constraints of previous view
    NSLayoutConstraint.deactivate(displayConstraints)
    /// Remove previous view
    self.payloadDisplay.subviews
      .forEach { (subview) in
        subview.removeFromSuperview()
    }
  }


  fileprivate func installPayloadDisplay(with payload: EventPayloadType) {
    self.uninstallPayloadDisplay()
    /// ask for a new view of current payload
    let v = EventTableViewCell.view(for: payload)
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


  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  internal static func estimatedHeight(with payload: EventPayloadType) -> CGFloat {
    return 130 + view(for: payload).frame.height
  }
}

extension EventTableViewCell {
  internal static func view(for payload: EventPayloadType) -> UIView {
    let height: CGFloat
    let color: UIColor
    switch payload {
    case let (forkPayload as ForkEventPayload):
      height = 40
      color = UIColor.black
    case let (createPayload as CreateEventPayload):
      height = 30
      color = UIColor.brown
    case let (pushPayload as PushEventPayload):
      height = 50
      color = UIColor.red
    case let (watchPayload as WatchEventPayload):
      height = 160
      color = UIColor.cyan
    default:
      height = 20
      color = UIColor.blue
    }
    let payloadView = UIView()
    payloadView.backgroundColor = color
    payloadView.frame = CGRect(x: 0, y: 0, width: 0, height: height)
    return payloadView
  }
}
































