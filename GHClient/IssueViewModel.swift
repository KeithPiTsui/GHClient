//
//  IssueViewModel.swift
//  GHClient
//
//  Created by Pi on 24/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import Prelude
import GHAPI

internal protocol IssueViewModelInputs {

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  /// Call when vc received an issue URL
  func set(issue url: URL)

  /// Call when vc recieved an issue
  func set(issue: Issue)
}

internal protocol IssueViewModelOutputs {

  var issue: Signal<Issue, NoError> { get }

  var issueComments: Signal<[IssueComment], NoError> { get }
  
}

internal protocol IssueViewModelType {
  var inputs: IssueViewModelInputs { get }
  var outpus: IssueViewModelOutputs { get }
}


internal final class IssueViewModel:
IssueViewModelType,
IssueViewModelInputs,
IssueViewModelOutputs {

  init() {
    let issueFromUrl = self.setIssueURLProperty.signal.skipNil()
      .observeInBackground()
      .map {AppEnvironment.current.apiService.issue(of: $0).single()?.value}
      .skipNil()
    let issue = Signal.merge(issueFromUrl, self.setIssueProperty.signal.skipNil())

    self.issue = Signal.combineLatest(issue, self.viewDidLoadProperty.signal)
      .map(first)

    let comments = issue
      .observeInBackground()
      .map {AppEnvironment.current.apiService.issueComments(of: $0).single()?.value}
      .skipNil()

    self.issueComments = comments
  }

  fileprivate let setIssueProperty = MutableProperty<Issue?>(nil)
  public func set(issue: Issue) {
    self.setIssueProperty.value = issue
  }

  fileprivate let setIssueURLProperty = MutableProperty<URL?>(nil)
  public func set(issue url: URL) {
    self.setIssueURLProperty.value = url
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

  internal let issue: Signal<Issue, NoError>
  internal let issueComments: Signal<[IssueComment], NoError>

  internal var inputs: IssueViewModelInputs { return self }
  internal var outpus: IssueViewModelOutputs { return self }
}
