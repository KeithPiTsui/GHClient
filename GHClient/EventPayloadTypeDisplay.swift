//
//  EventPayloadTypeExtension.swift
//  GHClient
//
//  Created by Pi on 22/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal protocol EventPayloadTypeDisplay: EventPayloadType {
  var payloadView: UIView { get }
}

extension EventPayloadType {
  public var payloadView: UIView {
    if let display = self as? EventPayloadTypeDisplay {
      return display.payloadView
    } else {
      return UIView()
    }
  }
}
