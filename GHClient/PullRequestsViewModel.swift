//
//  PullRequestsViewModel.swift
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

internal protocol PullRequestsViewModelInputs {

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  func set(pullRequests: [PullRequest], of repo: Repository)

  func set(pullRequestsBelongTo repo: Repository)
}

internal protocol PullRequestsViewModelOutputs {

  var pullRequests: Signal<[PullRequest], NoError> { get }
}

internal protocol PullRequestsViewModelType {
  var inputs: PullRequestsViewModelInputs { get }
  var outpus: PullRequestsViewModelOutputs { get }
}


internal final class PullRequestsViewModel:
PullRequestsViewModelType,
PullRequestsViewModelInputs,
PullRequestsViewModelOutputs {

  init() {
    let pr1 = self.setPullRequestsBelongToRepoProperty.signal.skipNil().observeInBackground().map { (repo) -> [PullRequest]? in
      AppEnvironment.current.apiService.pullRequests(of: repo).single()?.value
    }.skipNil()
    let pr2 = self.setPullRequestsOfRepoProperty.signal.skipNil().map(first)
    let pr = Signal.merge(pr1, pr2)
    self.pullRequests = Signal.combineLatest(pr, self.viewDidLoadProperty.signal).map(first)
  }

  fileprivate let setPullRequestsOfRepoProperty = MutableProperty<([PullRequest], Repository)?>(nil)
  internal func set(pullRequests: [PullRequest], of repo: Repository) {
    self.setPullRequestsOfRepoProperty.value = (pullRequests, repo)
  }

  fileprivate let setPullRequestsBelongToRepoProperty = MutableProperty<Repository?>(nil)
  internal func set(pullRequestsBelongTo repo: Repository) {
    self.setPullRequestsBelongToRepoProperty.value = repo
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

  internal let pullRequests: Signal<[PullRequest], NoError>

  internal var inputs: PullRequestsViewModelInputs { return self }
  internal var outpus: PullRequestsViewModelOutputs { return self }
}
