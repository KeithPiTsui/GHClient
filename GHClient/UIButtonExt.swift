//
//  UIButtonExt.swift
//  GHClient
//
//  Created by Pi on 18/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import Foundation

public typealias UIButtonClosureAction = () -> ()

extension UIButton {

  private enum ClosureHolder {
    fileprivate static var closure: UIButtonClosureAction?
  }

  private func set(_ action: @escaping UIButtonClosureAction) {
    ClosureHolder.closure = action
  }

  @objc private func triggerActionHandleBlock() {
    ClosureHolder.closure?()
  }

  public func attach(event controlEvent: UIControlEvents, with action: @escaping ()-> Void) {
    self.set(action)
    self.addTarget(self, action: #selector(UIButton.triggerActionHandleBlock), for: controlEvent)
  }
}
