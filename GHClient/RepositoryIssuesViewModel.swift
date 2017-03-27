//
//  RepositoryIssuesViewModel.swift
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

internal protocol RepositoryIssuesViewModelInputs {

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  func set(issues: [Issue], of repo: Repository)

  func set(issuesBelongTo repo: Repository)
}

internal protocol RepositoryIssuesViewModelOutputs {
  var issues: Signal<[Issue],NoError> {get}
}

internal protocol RepositoryIssuesViewModelType {
  var inputs: RepositoryIssuesViewModelInputs { get }
  var outpus: RepositoryIssuesViewModelOutputs { get }
}


internal final class RepositoryIssuesViewModel:
RepositoryIssuesViewModelType,
RepositoryIssuesViewModelInputs,
RepositoryIssuesViewModelOutputs {

  init() {
    let i1 = self.setIssuesOfRepoProperty.signal.skipNil().map(first)
    let i2 = self.setIssuesBelongToRepoProperty.signal.skipNil().observeInBackground().map { (repo) -> [Issue]? in
      AppEnvironment.current.apiService.issues(of: repo).single()?.value
    }.skipNil()
    let i = Signal.merge(i1, i2)
    self.issues = Signal.combineLatest(i, self.viewDidLoadProperty.signal).map(first)
  }

  fileprivate let setIssuesOfRepoProperty = MutableProperty<([Issue], Repository)?>(nil)
  internal func set(issues: [Issue], of repo: Repository) {
    self.setIssuesOfRepoProperty.value = (issues, repo)
  }

  fileprivate let setIssuesBelongToRepoProperty = MutableProperty<Repository?>(nil)
  internal func set(issuesBelongTo repo: Repository) {
    self.setIssuesBelongToRepoProperty.value = repo
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

  internal let issues: Signal<[Issue], NoError>

  internal var inputs: RepositoryIssuesViewModelInputs { return self }
  internal var outpus: RepositoryIssuesViewModelOutputs { return self }
}
