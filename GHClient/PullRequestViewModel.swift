//
//  PullRequestViewModel.swift
//  GHClient
//
//  Created by Pi on 03/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import Prelude
import GHAPI

internal protocol PullRequestViewModelInputs {

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  func set(pullRequest: URL)

  func set(pullRequest: PullRequest)
}

internal protocol PullRequestViewModelOutputs {

  var pullRequest: Signal<PullRequest, NoError> { get }
  var commemts: Signal<[IssueComment], NoError> { get }

}

internal protocol PullRequestViewModelType {
  var inputs: PullRequestViewModelInputs { get }
  var outpus: PullRequestViewModelOutputs { get }
}


internal final class PullRequestViewModel:
PullRequestViewModelType,
PullRequestViewModelInputs,
PullRequestViewModelOutputs {

  init() {
    let pr1 = self.setPullRequestProperty.signal.skipNil()
    let pr2 = self.setPullRequestURLProperty.signal.skipNil().observeInBackground()
      .map { AppEnvironment.current.apiService.pullRequest(of: $0).single()?.value}
      .skipNil()
    let pr = Signal.merge(pr1, pr2)
    self.pullRequest = Signal.combineLatest(pr, self.viewDidLoadProperty.signal).map(first)
    self.commemts = pr.observeInBackground()
      .map {AppEnvironment.current.apiService.pullRequestComments(of: $0).single()?.value}
      .skipNil()
  }

  fileprivate let setPullRequestURLProperty = MutableProperty<URL?>(nil)
  internal func set(pullRequest: URL) {
    self.setPullRequestURLProperty.value = pullRequest
  }

  fileprivate let setPullRequestProperty = MutableProperty<PullRequest?>(nil)
  internal func set(pullRequest: PullRequest) {
    self.setPullRequestProperty.value = pullRequest
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

  internal let pullRequest: Signal<PullRequest, NoError>
  internal let commemts: Signal<[IssueComment], NoError>

  internal var inputs: PullRequestViewModelInputs { return self }
  internal var outpus: PullRequestViewModelOutputs { return self }
}
