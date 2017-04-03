//
//  CommitViewModel.swift
//  GHClient
//
//  Created by Pi on 30/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import Prelude
import GHAPI

internal protocol CommitViewModelInputs {

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  func set(commit: Commit)

  func set(commit: URL)
}

internal protocol CommitViewModelOutputs {

  var commit: Signal<Commit, NoError> { get }

  var commitChanges: Signal<([Commit.CFile], [CommitDatasource.CommitChangesType]), NoError> {get}

  var commitComments: Signal<[CommitComment], NoError> {get}
}

internal protocol CommitViewModelType {
  var inputs: CommitViewModelInputs { get }
  var outpus: CommitViewModelOutputs { get }
}


internal final class CommitViewModel:
CommitViewModelType,
CommitViewModelInputs,
CommitViewModelOutputs {

  init() {
    let c1 = self.setCommitProperty.signal.skipNil()
    let c2 = self.setCommitURLProperty.signal.skipNil().observeInBackground().map { (url) -> Commit? in
      AppEnvironment.current.apiService.commit(referredBy: url).single()?.value
    }.skipNil()
    let c = Signal.merge(c1, c2)
    self.commit = Signal.combineLatest(c, self.viewDidLoadProperty.signal).map(first)

    let files = self.commit.map{$0.files}.skipNil()
    self.commitChanges = files.map{($0, CommitDatasource.CommitChangesType.allCases)}

    self.commitComments = self.commit.map{ (commit) -> [CommitComment]? in
      AppEnvironment.current.apiService.comments(of: commit).single()?.value
    }.skipNil()
  }

  fileprivate let setCommitProperty = MutableProperty<Commit?>(nil)
  public func set(commit: Commit) {
    self.setCommitProperty.value = commit
  }

  fileprivate let setCommitURLProperty = MutableProperty<URL?>(nil)
  public func set(commit: URL) {
    self.setCommitURLProperty.value = commit
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

  internal let commit: Signal<Commit, NoError>
  internal let commitChanges: Signal<([Commit.CFile], [CommitDatasource.CommitChangesType]), NoError>
  internal let commitComments: Signal<[CommitComment], NoError>

  internal var inputs: CommitViewModelInputs { return self }
  internal var outpus: CommitViewModelOutputs { return self }
}
