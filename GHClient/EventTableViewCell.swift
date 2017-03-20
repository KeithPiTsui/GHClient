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
    self.eventDesc.text = value.id
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
      .forEach {$0.removeFromSuperview()}
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
    return 105 + view(for: payload).frame.height
  }
}

extension EventTableViewCell {
  internal static func view(for payload: EventPayloadType) -> UIView {
    let payloadView: UIView
    switch payload {
    case let (forkPayload as ForkEventPayload):
      let lab = UILabel(frame: UIScreen.main.bounds)
      lab.numberOfLines = 0
      lab.text = forkPayload.forkee.description ?? ""
      lab.sizeToFit()
      payloadView = lab
    case (_ as CreateEventPayload):
      payloadView = UIView(frame: CGRect.zero)
      payloadView.backgroundColor = UIColor.brown
    case let (pushPayload as PushEventPayload):
      let str = pushPayload.commits.reduce("", { (str, commit) -> String in
        let sha = commit.sha?.last(8) ?? ""
        let msg  = commit.message
        return str + "\n" + sha + " " + msg
      }).trimmingCharacters(in: .whitespacesAndNewlines)
      let lab = UILabel(frame: UIScreen.main.bounds)
      lab.numberOfLines = 0
      lab.font = UIFont.systemFont(ofSize: 12)
      lab.text = str
      lab.sizeToFit()
      payloadView = lab
    case (_ as WatchEventPayload):
      payloadView = UIView(frame: CGRect.zero)
    default:
      payloadView = UIView(frame: CGRect.zero)
    }
    return payloadView
  }
}
































