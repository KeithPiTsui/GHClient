//
//  DiscoveryViewModel.swift
//  GHClient
//
//  Created by Pi on 14/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import GHAPI
import Prelude

internal protocol DiscoveryViewModelInputs {
  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when user tapped on one trending repo
  func userTapped(on repo: TrendingRepository)
}

internal protocol DiscoveryViewModelOutputs{

  var repositories: Signal<[TrendingRepository], NoError> { get }

  var pushRepoViewController: Signal<RepositoryViewController, NoError> {get}
}

internal protocol DiscoveryViewModelType{
  var inputs: DiscoveryViewModelInputs {get}
  var outputs: DiscoveryViewModelOutputs { get }

}

internal final class DiscoveryViewModel: DiscoveryViewModelType, DiscoveryViewModelInputs, DiscoveryViewModelOutputs {

  init() {
    let repos = self.viewDidLoadProperty.signal.observe(on: QueueScheduler())
      .map { _ in AppEnvironment.current.apiService.trendingRepository(of: .daily, with: "swift").single()?.value}
      .skipNil()
    self.repositories = Signal.combineLatest(repos, self.viewWillAppearProperty.signal).map(first)
    
    let repoUrl = self.userTappedTrendingOnRepoProperty.signal.skipNil().map { (trendingRepo) -> URL? in
      guard
        let owner = trendingRepo.repoOwner,
        let repo = trendingRepo.repoName
        else { return nil }
      return AppEnvironment.current.apiService.repositoryUrl(of: owner, and: repo)
    }.skipNil()

    self.pushRepoViewController = repoUrl
      .map{ (url) -> RepositoryViewController in
        let vc = RepositoryViewController.instantiate()
        vc.set(repoURL: url); return vc
    }
  }

  fileprivate let userTappedTrendingOnRepoProperty = MutableProperty<TrendingRepository?>(nil)
  internal func userTapped(on repo: TrendingRepository) {
    self.userTappedTrendingOnRepoProperty.value = repo
  }

  fileprivate let userSessionStartedProperty = MutableProperty(())
  internal func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }
  fileprivate let userSessionEndedProperty = MutableProperty(())
  internal func userSessionEnded() {
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

  internal let pushRepoViewController: Signal<RepositoryViewController, NoError>
  internal let repositories: Signal<[TrendingRepository], NoError>

  internal var inputs: DiscoveryViewModelInputs { return self }
  internal var outputs: DiscoveryViewModelOutputs { return self }
}























