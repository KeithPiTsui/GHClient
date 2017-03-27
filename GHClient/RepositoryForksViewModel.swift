//
//  RepositoryForksViewModel.swift
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

internal protocol RepositoryForksViewModelInputs {

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  func set(forks: [Repository], of repo: Repository)

  func set(forksBelongTo repo: Repository)
}

internal protocol RepositoryForksViewModelOutputs {

  var forks: Signal<[Repository], NoError> { get }

}

internal protocol RepositoryForksViewModelType {
  var inputs: RepositoryForksViewModelInputs { get }
  var outpus: RepositoryForksViewModelOutputs { get }
}


internal final class RepositoryForksViewModel:
RepositoryForksViewModelType,
RepositoryForksViewModelInputs,
RepositoryForksViewModelOutputs {

  init() {
    let forks1 = self.setForksOfRepositoryProperty.signal.skipNil().map(first)
    let forks2 = self.setForksBelongToRepoProperty.signal.skipNil()
      .observeInBackground()
      .map { (repo) -> [Repository]? in
      AppEnvironment.current.apiService.forks(of: repo).single()?.value
    }.skipNil()

    let forksSignal = Signal.merge(forks1, forks2)
    self.forks = Signal.combineLatest(forksSignal, self.viewDidLoadProperty.signal).map(first)
  }

  fileprivate let setForksOfRepositoryProperty = MutableProperty<([Repository], Repository)?>(nil)
  internal func set(forks: [Repository], of repo: Repository) {
    self.setForksOfRepositoryProperty.value = (forks, repo)
  }

  fileprivate let setForksBelongToRepoProperty = MutableProperty<Repository?>(nil)
  internal func set(forksBelongTo repo: Repository) {
    self.setForksBelongToRepoProperty.value = repo
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

  internal let forks: Signal<[Repository], NoError>

  internal var inputs: RepositoryForksViewModelInputs { return self }
  internal var outpus: RepositoryForksViewModelOutputs { return self }
}
