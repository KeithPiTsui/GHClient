//
//  EventTableViewCellViewModel.swift
//  GHClient
//
//  Created by Pi on 04/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import Prelude
import GHAPI

internal protocol EventTableViewCellViewModelInputs {

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()
}

internal protocol EventTableViewCellViewModelOutputs {

}

internal protocol EventTableViewCellViewModelType {
  var inputs: EventTableViewCellViewModelInputs { get }
  var outpus: EventTableViewCellViewModelOutputs { get }
}


internal final class EventTableViewCellViewModel:
EventTableViewCellViewModelType,
EventTableViewCellViewModelInputs,
EventTableViewCellViewModelOutputs {

  init() {
  }

  fileprivate let userSessionStartedProperty = MutableProperty(())
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }
  fileprivate let userSessionEndedProperty = MutableProperty(())
  public func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let viewWillAppearProperty = MutableProperty<Bool?>(nil)
  internal func viewWillAppear(animated: Bool) {
    self.viewWillAppearProperty.value = animated
  }

  internal var inputs: EventTableViewCellViewModelInputs { return self }
  internal var outpus: EventTableViewCellViewModelOutputs { return self }
}
