//
//  RepositoryViewModel.swift
//  GHClient
//
//  Created by Pi on 11/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import GHAPI
import Prelude

internal protocol RepositoryViewModelInputs {
  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  /// Call when vc receive a repository to display
  func set(repo: Repository)

  /// Call when vc receive a url to repository for display
  func set(repoURL: URL)

  /// Call when user tapped on readme option
  func gotoReadme()

  /// Call when user tapped on a branch
  func goto(branch: BranchLite)
}

internal protocol RepositoryViewModelOutputs {

  var brief: Signal<(a:String, b: String, c: String, d: String), NoError> {get}

  var repository: Signal<Repository,NoError> { get }

  var branchLites: Signal<[BranchLite], NoError> {get}

  var commits: Signal<[Commit], NoError> {get}

  var details: Signal<[(UIImage?, String)], NoError> {get}

  var gotoReadmeVC: Signal<UIViewController, NoError> {get}

  var gotoBranchVC: Signal<RepositoryContentTableViewController, NoError> { get }
}

internal protocol RepositoryViewModelType {
  var inputs: RepositoryViewModelInputs { get }
  var outputs: RepositoryViewModelOutputs { get }
}

internal final class RepositoryViewModel: RepositoryViewModelType, RepositoryViewModelInputs, RepositoryViewModelOutputs {

  init() {
    let repo1 = self.setRepoURLProperty.signal.skipNil().observe(on: QueueScheduler())
      .map {AppEnvironment.current.apiService.repository(referredBy: $0).single()}
      .map {$0?.value}.skipNil()
    let repo2 = self.setRepoProperty.signal.skipNil()
    let repo = Signal.merge(repo1, repo2)
    let repoDisplay = Signal.combineLatest(repo, self.viewDidLoadProperty.signal).map(first)

    self.repository = repoDisplay

    self.commits = repoDisplay.observe(on: QueueScheduler()).map { (repo) -> [Commit]? in
      AppEnvironment.current.apiService.commits(referredBy: repo.urls.commits_url).single()?.value
      }.skipNil()

    self.branchLites = repoDisplay.observe(on: QueueScheduler()).map { (repo) -> [BranchLite]? in
      AppEnvironment.current.apiService.branchLites(referredBy: repo.urls.branches_url).single()?.value
      }.skipNil()

    self.brief = repoDisplay.map{ (repo) -> (a:String, b: String, c: String, d: String) in
      ("owner", repo.owner.login, repo.desc ?? "No Description", "README")
    }

    self.details = self.viewWillAppearProperty.signal.map {_ in
      guard let img = UIImage(named: "phone-icon") else { fatalError("No such image phone_icon") }
      return [(img, "Forks"),
              (img, "Releases"),
              (img, "Recent Activity"),
              (img, "Contributors"),
              (img, "Stargazers"),
              (img, "Pull Requests"),
              (img, "Issues")]
    }

    let vc = self.viewDidLoadProperty.signal.map { () -> ReadmeViewController in
      ReadmeViewController.instantiate()
    }

    let readmeURL = repoDisplay.map { (repo) -> URL? in
      let rmURL = repo.urls.url.appendingPathComponent("/readme")
      return AppEnvironment.current.apiService.readme(referredBy: rmURL).single()?.value?.html_url
      }.skipNil()

    let readmeVC = Signal.combineLatest(vc, readmeURL).map { (vc, url) -> UIViewController in
      vc.set(readmeUrl: url)
      return vc
    }
    self.gotoReadmeVC = Signal.combineLatest(readmeVC, self.gotoReadmeProperty.signal).map(first)


    self.gotoBranchVC =
      Signal.combineLatest(self.gotoBranchProperty.signal.skipNil(), repoDisplay)
        .map { (branch, repo) -> RepositoryContentTableViewController in
          let rc = RepositoryContentTableViewController.instantiate()
          rc.set(repo: repo, and: branch)
          return rc
    }

  }

  fileprivate let gotoBranchProperty = MutableProperty<BranchLite?>(nil)
  public func goto(branch: BranchLite) {
    self.gotoBranchProperty.value = branch
  }

  fileprivate let gotoReadmeProperty = MutableProperty()
  public func gotoReadme() {
    self.gotoReadmeProperty.value = ()
  }

  fileprivate let setRepoProperty = MutableProperty<Repository?>(nil)
  public func set(repo: Repository) {
    self.setRepoProperty.value = repo
  }

  fileprivate let setRepoURLProperty = MutableProperty<URL?>(nil)
  public func set(repoURL: URL) {
    self.setRepoURLProperty.value = repoURL
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

  internal let brief: Signal<(a: String, b: String, c: String, d: String), NoError>
  internal let details: Signal<[(UIImage?, String)], NoError>

  internal let repository: Signal<Repository, NoError>
  internal let branchLites: Signal<[BranchLite], NoError>
  internal let commits: Signal<[Commit], NoError>
  internal let gotoReadmeVC: Signal<UIViewController, NoError>
  internal let gotoBranchVC: Signal<RepositoryContentTableViewController, NoError>

  internal var inputs: RepositoryViewModelInputs { return self }
  internal var outputs: RepositoryViewModelOutputs { return self }
}
