//
//  ChangedFilesViewModel.swift
//  GHClient
//
//  Created by Pi on 10/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import Prelude
import GHAPI

internal protocol ChangedFilesViewModelInputs {

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  func set(files: [Commit.CFile])
}

internal protocol ChangedFilesViewModelOutputs {
  var files: Signal<[Commit.CFile], NoError> { get }
}

internal protocol ChangedFilesViewModelType {
  var inputs: ChangedFilesViewModelInputs { get }
  var outpus: ChangedFilesViewModelOutputs { get }
}


internal final class ChangedFilesViewModel:
ChangedFilesViewModelType,
ChangedFilesViewModelInputs,
ChangedFilesViewModelOutputs {

  init() {
    self.files = Signal.combineLatest(self.setFilesProperty.signal.skipNil(), self.viewDidLoadProperty.signal).map(first)
  }

  fileprivate let setFilesProperty = MutableProperty<[Commit.CFile]?>(nil)
  internal func set(files: [Commit.CFile]) {
    self.setFilesProperty.value = files
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

  internal let files: Signal<[Commit.CFile], NoError>

  internal var inputs: ChangedFilesViewModelInputs { return self }
  internal var outpus: ChangedFilesViewModelOutputs { return self }
}
