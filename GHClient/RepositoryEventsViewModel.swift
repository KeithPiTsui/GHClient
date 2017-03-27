//
//  RepositoryEventsViewModel.swift
//  GHClient
//
//  Created by Pi on 27/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import Prelude
import GHAPI

internal protocol RepositoryEventsViewModelInputs {

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  func set(events: [GHEvent], of Repo: Repository)

  func set(eventsBelongTo repo: Repository)
}

internal protocol RepositoryEventsViewModelOutputs {
  var events: Signal<[GHEvent], NoError> { get }
}

internal protocol RepositoryEventsViewModelType {
  var inputs: RepositoryEventsViewModelInputs { get }
  var outpus: RepositoryEventsViewModelOutputs { get }
}


internal final class RepositoryEventsViewModel:
RepositoryEventsViewModelType,
RepositoryEventsViewModelInputs,
RepositoryEventsViewModelOutputs {

  init() {
    let e1 = self.setEventsOfRepoProperty.signal.skipNil().map(first)
    let e2 = self.setEventsBelongToRepoProperty.signal.skipNil().observeInBackground().map { (repo) -> [GHEvent]? in
      AppEnvironment.current.apiService.events(of: repo).single()?.value
    }.skipNil()

    let e = Signal.merge(e1, e2)
    self.events = Signal.combineLatest(e, self.viewDidLoadProperty.signal).map(first)
  }

  fileprivate let setEventsOfRepoProperty = MutableProperty<([GHEvent], Repository)?>(nil)
  internal func set(events: [GHEvent], of repo: Repository) {
    self.setEventsOfRepoProperty.value = (events, repo)
  }

  fileprivate let setEventsBelongToRepoProperty = MutableProperty<Repository?>(nil)
  internal func set(eventsBelongTo repo: Repository)  {
    self.setEventsBelongToRepoProperty.value = repo
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

  internal let events: Signal<[GHEvent], NoError>

  internal var inputs: RepositoryEventsViewModelInputs { return self }
  internal var outpus: RepositoryEventsViewModelOutputs { return self }
}
