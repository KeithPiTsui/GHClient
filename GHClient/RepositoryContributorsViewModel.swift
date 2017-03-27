//
//  RepositoryContributorsViewModel.swift
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

internal protocol RepositoryContributorsViewModelInputs {

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  func set(contributors: [UserLite], of repo: Repository)

  func set(contributorsBelongTo repo: Repository)
}

internal protocol RepositoryContributorsViewModelOutputs {
  var contributors: Signal<[UserLite], NoError> { get }
}

internal protocol RepositoryContributorsViewModelType {
  var inputs: RepositoryContributorsViewModelInputs { get }
  var outpus: RepositoryContributorsViewModelOutputs { get }
}


internal final class RepositoryContributorsViewModel:
RepositoryContributorsViewModelType,
RepositoryContributorsViewModelInputs,
RepositoryContributorsViewModelOutputs {

  init() {
    let c1 = self.setContributorBelongToRepoProperty.signal.skipNil().observeInBackground()
      .map { (repo) -> [UserLite]? in
      AppEnvironment.current.apiService.contributors(of: repo).single()?.value
    }.skipNil()
    let c2 = self.setContributorsOfRepoProperty.signal.skipNil().map(first)
    let c = Signal.merge(c1, c2)
    self.contributors = Signal.combineLatest(c, self.viewDidLoadProperty.signal).map(first)

  }

  fileprivate let setContributorsOfRepoProperty = MutableProperty<([UserLite], Repository)?>(nil)
  internal func set(contributors: [UserLite], of repo: Repository) {
    self.setContributorsOfRepoProperty.value = (contributors, repo)
  }

  fileprivate let setContributorBelongToRepoProperty = MutableProperty<Repository?>(nil)
  internal func set(contributorsBelongTo repo: Repository) {
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
  internal let contributors: Signal<[UserLite], NoError>

  internal var inputs: RepositoryContributorsViewModelInputs { return self }
  internal var outpus: RepositoryContributorsViewModelOutputs { return self }
}
