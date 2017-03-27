//
//  RepositoryStargazersViewModel.swift
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

internal protocol RepositoryStargazersViewModelInputs {

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  func set(stargazers: [UserLite], of repo: Repository)

  func set(stargazersBelongTo repo: Repository)
}

internal protocol RepositoryStargazersViewModelOutputs {
  var stargazers: Signal<[UserLite], NoError> { get }
}

internal protocol RepositoryStargazersViewModelType {
  var inputs: RepositoryStargazersViewModelInputs { get }
  var outpus: RepositoryStargazersViewModelOutputs { get }
}


internal final class RepositoryStargazersViewModel:
RepositoryStargazersViewModelType,
RepositoryStargazersViewModelInputs,
RepositoryStargazersViewModelOutputs {

  init() {
    let c1 = self.setContributorBelongToRepoProperty.signal.skipNil().observeInBackground()
      .map { (repo) -> [UserLite]? in
      AppEnvironment.current.apiService.stargazers(of: repo).single()?.value
    }.skipNil()
    let c2 = self.setStargazersOfRepoProperty.signal.skipNil().map(first)
    let c = Signal.merge(c1, c2)
    self.stargazers = Signal.combineLatest(c, self.viewDidLoadProperty.signal).map(first)

  }

  fileprivate let setStargazersOfRepoProperty = MutableProperty<([UserLite], Repository)?>(nil)
  internal func set(stargazers: [UserLite], of repo: Repository) {
    self.setStargazersOfRepoProperty.value = (stargazers, repo)
  }

  fileprivate let setContributorBelongToRepoProperty = MutableProperty<Repository?>(nil)
  internal func set(stargazersBelongTo repo: Repository) {
    self.setContributorBelongToRepoProperty.value = repo
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
  internal let stargazers: Signal<[UserLite], NoError>

  internal var inputs: RepositoryStargazersViewModelInputs { return self }
  internal var outpus: RepositoryStargazersViewModelOutputs { return self }
}
