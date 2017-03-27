//
//  RepositoryReleasesViewModel.swift
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

internal protocol RepositoryReleasesViewModelInputs {

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  func set(releases: [Release], of repo: Repository)

  func set(releasesBelongTo repo: Repository)
}

internal protocol RepositoryReleasesViewModelOutputs {
  var releases: Signal<[Release], NoError> { get }
}

internal protocol RepositoryReleasesViewModelType {
  var inputs: RepositoryReleasesViewModelInputs { get }
  var outpus: RepositoryReleasesViewModelOutputs { get }
}


internal final class RepositoryReleasesViewModel:
RepositoryReleasesViewModelType,
RepositoryReleasesViewModelInputs,
RepositoryReleasesViewModelOutputs {

  init() {
    let r1 = self.setReleasesBelongToRepoProperty.signal.skipNil().observeInBackground().map { (repo) -> [Release]? in
      AppEnvironment.current.apiService.releases(of: repo).single()?.value
    }.skipNil()
    let r2 = self.setReleasesOfRepoProperty.signal.skipNil().map(first)
    let r = Signal.merge(r1, r2)
    self.releases = Signal.combineLatest(r, self.viewDidLoadProperty.signal).map(first)
  }

  fileprivate let setReleasesOfRepoProperty = MutableProperty<([Release], Repository)?>(nil)
  internal func set(releases: [Release], of repo: Repository) {
    self.setReleasesOfRepoProperty.value = (releases, repo)
  }

  fileprivate let setReleasesBelongToRepoProperty = MutableProperty<Repository?>(nil)
  internal func set(releasesBelongTo repo: Repository) {
    self.setReleasesBelongToRepoProperty.value = repo
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

  internal let releases: Signal<[Release], NoError>

  internal var inputs: RepositoryReleasesViewModelInputs { return self }
  internal var outpus: RepositoryReleasesViewModelOutputs { return self }
}
