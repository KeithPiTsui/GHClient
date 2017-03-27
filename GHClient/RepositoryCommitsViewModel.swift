//
//  RepositoryCommitsViewModel.swift
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

internal protocol RepositoryCommitsViewModelInputs {

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  func set(commits: [Commit], of repo: Repository, on branch: BranchLite)

  func set(commitsBelongTo repo: Repository, on branch: BranchLite)
}

internal protocol RepositoryCommitsViewModelOutputs {
  var commits: Signal<[Commit],NoError> { get }
}

internal protocol RepositoryCommitsViewModelType {
  var inputs: RepositoryCommitsViewModelInputs { get }
  var outpus: RepositoryCommitsViewModelOutputs { get }
}


internal final class RepositoryCommitsViewModel:
RepositoryCommitsViewModelType,
RepositoryCommitsViewModelInputs,
RepositoryCommitsViewModelOutputs {

  init() {
    let c1 = self.setCommitsOfRepoOnBranchProperty.signal.skipNil().map(first)
    let c2 = self.setCommitsBelongToRepoOnBranchProperty.signal.skipNil().observeInBackground()
      .map { (repo, branch) -> [Commit]? in
      AppEnvironment.current.apiService.commits(of: repo, on: branch).single()?.value
    }.skipNil()
    let c = Signal.merge(c1, c2)
    self.commits = Signal.combineLatest(c, self.viewDidLoadProperty.signal).map(first)
  }

  fileprivate let setCommitsOfRepoOnBranchProperty = MutableProperty<([Commit], Repository, BranchLite)?>(nil)
  internal func set(commits: [Commit], of repo: Repository, on branch: BranchLite) {
    self.setCommitsOfRepoOnBranchProperty.value = (commits, repo, branch)
  }

  fileprivate let setCommitsBelongToRepoOnBranchProperty = MutableProperty<(Repository, BranchLite)?>(nil)
  internal func set(commitsBelongTo repo: Repository, on branch: BranchLite) {
    self.setCommitsBelongToRepoOnBranchProperty.value = (repo, branch)
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

  internal let commits: Signal<[Commit], NoError>

  internal var inputs: RepositoryCommitsViewModelInputs { return self }
  internal var outpus: RepositoryCommitsViewModelOutputs { return self }
}
