//
//  MeViewModel.swift
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

internal protocol MeViewModelInputs {

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  /// Call when brief setuped
  func briefSetupCompleted()
}

internal protocol MeViewModelOutputs {
  var user: Signal<User, NoError> { get }

  var personalRepositories: Signal<[Repository], NoError> {get}

//  var watchedRepositories: Signal<[Repository], NoError> { get }

  var starredRepositories: Signal<[Repository], NoError> { get }

//  var issues: Signal<[Issue], NoError> { get }
//
//  var pullRequests: Signal<[PullRequest], NoError> {get}
}

internal protocol MeViewModelType {
  var inputs: MeViewModelInputs { get }
  var outpus: MeViewModelOutputs { get }
}


internal final class MeViewModel:
MeViewModelType,
MeViewModelInputs,
MeViewModelOutputs {

  init() {
    self.user = self.viewDidLoadProperty.signal
      .map{AppEnvironment.current.currentUser}
      .skipNil()

    let personalRepos = self.user.observeInBackground()
      .map { (user) -> [Repository]? in
      AppEnvironment.current.apiService.personalRepositories(of: user).single()?.value
    }.skipNil()

    let starredRepos = self.user.observeInBackground()
      .map { (user) -> [Repository]? in
      AppEnvironment.current.apiService.starredRepositories(of: user).single()?.value
      }.skipNil()

    self.personalRepositories = Signal.combineLatest(personalRepos, self.briefSetupCompletedProperty.signal).map(first)
    self.starredRepositories = Signal.combineLatest(starredRepos, self.briefSetupCompletedProperty.signal).map(first)
  }

  fileprivate let briefSetupCompletedProperty = MutableProperty()
  internal func briefSetupCompleted() {
    self.briefSetupCompletedProperty.value = ()
  }

  fileprivate let userSessionStartedProperty = MutableProperty(())
  internal func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }
  fileprivate let userSessionEndedProperty = MutableProperty(())
  internal func userSessionEnded() {
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

  internal let user: Signal<User, NoError>
  internal let personalRepositories: Signal<[Repository], NoError>
//  internal let watchedRepositories: Signal<[Repository], NoError>
  internal let starredRepositories: Signal<[Repository], NoError>
//  internal let issues: Signal<[Issue], NoError>
//  internal let pullRequests: Signal<[PullRequest], NoError>

  internal var inputs: MeViewModelInputs { return self }
  internal var outpus: MeViewModelOutputs { return self }
}
