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

  ///
  func datasourceInitialized()

  func click (repoOwner: UserLite)
  func click (readme: Readme?)
  func click (forks: [Repository]?)
  func click (releases: [Release]?)
  func click (activities: [GHEvent]?)
  func click (contributors: [UserLite]?)
  func click (stargazers: [UserLite]?)
  func click (pullRequests: [PullRequest]?)
  func click (issues: [Issue]?)
  func click (branch: BranchLite)
  func clickCommits(on branch: BranchLite)

}

internal protocol RepositoryViewModelOutputs {

  var repository: Signal<Repository,NoError> { get }

  var repoReadme: Signal<Readme?, NoError> {get}

  var repoForks: Signal<[Repository], NoError> {get}

  var repoReleases: Signal<[Release], NoError> {get}

  var repoActivities: Signal<[GHEvent], NoError> {get}

  var repoContributors: Signal<[UserLite], NoError> {get}

  var repoStargazers: Signal<[UserLite], NoError> {get}

  var repoPullRequests: Signal<[PullRequest], NoError> { get }

  var repoIssues: Signal<[Issue], NoError> { get }

  var branchLites: Signal<[BranchLite], NoError> {get}

  var commits: Signal<[Commit], NoError> {get}

  var pushViewController: Signal<UIViewController, NoError> { get }

  var popupViewController: Signal<UIViewController, NoError> {get}
}

internal protocol RepositoryViewModelType {
  var inputs: RepositoryViewModelInputs { get }
  var outputs: RepositoryViewModelOutputs { get }
}

internal final class RepositoryViewModel: RepositoryViewModelType, RepositoryViewModelInputs, RepositoryViewModelOutputs {

  init() {
    let repo1 = self.setRepoURLProperty.signal.skipNil().observeInBackground()
      .map {AppEnvironment.current.apiService.repository(referredBy: $0).single()}
      .map {$0?.value}.skipNil()
    let repo2 = self.setRepoProperty.signal.skipNil()
    let repo = Signal.merge(repo1, repo2)
    self.repository = Signal.combineLatest(repo, self.viewDidLoadProperty.signal).map(first)

    let repoDisplay = Signal.combineLatest(self.repository, self.datasourceInitializedProperty.signal).map(first)

    self.repoReadme = repoDisplay.map { (repo) -> Readme? in
      let rmURL = repo.urls.url.appendingPathComponent("/readme")
      return AppEnvironment.current.apiService.readme(referredBy: rmURL).single()?.value}

    self.repoForks = repoDisplay.observeInBackground()
      .map{ (repo) -> [Repository]? in
        AppEnvironment.current.apiService.forks(of: repo).single()?.value
      }.skipNil()

    self.repoReleases = repoDisplay.observeInBackground()
      .map{ (repo) -> [Release]? in
        AppEnvironment.current.apiService.releases(of: repo).single()?.value
      }.skipNil()

    self.repoActivities = repoDisplay.observeInBackground()
      .map { (repo) -> [GHEvent]? in
        AppEnvironment.current.apiService.events(of: repo).single()?.value
      }.skipNil()

    self.repoContributors = repoDisplay.observeInBackground()
      .map { (repo) -> [UserLite]? in
        AppEnvironment.current.apiService.contributors(of: repo).single()?.value
      }.skipNil()

    self.repoStargazers = repoDisplay.observeInBackground()
      .map { (repo) -> [UserLite]? in
        AppEnvironment.current.apiService.stargazers(of: repo).single()?.value
      }.skipNil()

    self.repoPullRequests = repoDisplay.observeInBackground()
      .map { (repo) -> [PullRequest]? in
        AppEnvironment.current.apiService.pullRequests(of: repo).single()?.value
      }.skipNil()

    self.repoIssues = repoDisplay.observeInBackground()
      .map { (repo) -> [Issue]? in
        AppEnvironment.current.apiService.issues(of: repo).single()?.value
      }.skipNil()

    self.commits = repoDisplay.observeInBackground()
      .map { (repo) -> [Commit]? in
        AppEnvironment.current.apiService.commits(referredBy: repo.urls.commits_url).single()?.value
      }.skipNil()

    self.branchLites = repoDisplay.observeInBackground()
      .map { (repo) -> [BranchLite]? in
        AppEnvironment.current.apiService.branchLites(referredBy: repo.urls.branches_url).single()?.value
      }.skipNil()


    let alertVC = self.viewDidLoadProperty.signal.map {() -> UIAlertController in
      let vc = UIAlertController(title: "", message: "", preferredStyle: .alert)
      vc.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
      return vc
    }

    let alertSituation1 = self.clickReadmeProperty.signal.filter{$0.isNil}.map{_ in "No Readme"}
    let alertSituation2 = self.clickForksProperty.signal.skipNil().filter{$0.isEmpty}.map{_ in "No Fork"}
    let alertSituation3 = self.clickReleasesProperty.signal.skipNil().filter{$0.isEmpty}.map{_ in "No Release"}
    let alertSituation4 = self.clickActivitiesProperty.signal.skipNil().filter{$0.isEmpty}.map{_ in "No Activity"}
    let alertSituation5 = self.clickContributorsProperty.signal.skipNil().filter{$0.isEmpty}.map{_ in "No Contributor"}
    let alertSituation6 = self.clickStargazersProperty.signal.skipNil().filter{$0.isEmpty}.map{_ in "No Stargazers"}
    let alertSituation7 = self.clickPullRequestsProperty.signal.skipNil().filter{$0.isEmpty}.map{_ in "No Pull Request"}
    let alertSituation8 = self.clickIssuesProperty.signal.skipNil().filter{$0.isEmpty}.map{_ in "No Issue"}

    let alertSituations = Signal.merge(alertSituation1,
                                       alertSituation2,
                                       alertSituation3,
                                       alertSituation4,
                                       alertSituation5,
                                       alertSituation6,
                                       alertSituation7,
                                       alertSituation8)

    self.popupViewController = Signal.combineLatest(alertVC, alertSituations)
      .map { (altVC, message) -> UIViewController in
        altVC.message = message
        return altVC
    }

    let pushReadmeVC = self.clickReadmeProperty.signal.skipNil()
      .map { (readme) -> UIViewController in
        let vc = ReadmeViewController.instantiate()
        vc.set(readmeUrl: readme.html_url)
        return vc
    }

    let pushBranchContent =
      Signal.combineLatest(self.clickBranchProperty.signal.skipNil(), repoDisplay)
        .map { (branch, repo) -> UIViewController in
          let rc = RepositoryContentTableViewController.instantiate()
          rc.set(repo: repo, and: branch)
          return rc
    }



    let pushOwnerVC = self.clickRepoOwnerProperty.signal.skipNil()
      .map { (owner) -> UIViewController in
        let userVC =  UserProfileViewController.instantiate()
        userVC.set(userUrl: owner.urls.url)
        return userVC
    }


    let callForForks = self.clickForksProperty.signal.filter { $0.isNil || ($0!.isEmpty == false) }
    let pushForksVC = Signal.combineLatest(callForForks, repoDisplay)
      .map { (forks, repo) -> UIViewController in
        let vc = RepositoryForksTableViewController.instantiate()
        if let forks = forks {
          vc.set(forks: forks, of: repo)
        } else {
          vc.set(forksBelongTo: repo)
        }
        return vc
    }

    let callForReleases = self.clickReleasesProperty.signal.filter { $0.isNil || ($0!.isEmpty == false) }
    let pushReleasesVC = Signal.combineLatest(callForReleases, repoDisplay)
      .map { (releases, repo) -> UIViewController in
        let vc = RepositoryReleasesTableViewController.instantiate()
        if let releases = releases {
          vc.set(releases: releases, of: repo)
        } else {
          vc.set(releasesBelongTo: repo)
        }
        return vc
    }


    let callForActivities = self.clickActivitiesProperty.signal.filter { $0.isNil || ($0!.isEmpty == false) }
    let pushActivitiesVC = Signal.combineLatest(callForActivities, repoDisplay)
      .map { (activities, repo) -> UIViewController in
        let vc = RepositoryEventsTableViewController.instantiate()
        if let activities = activities {
          vc.set(events: activities, of: repo)
        } else {
          vc.set(eventsBelongTo: repo)
        }
        return vc
    }


    let callForContributors = self.clickContributorsProperty.signal.filter { $0.isNil || ($0!.isEmpty == false) }
    let pushContributorsVC = Signal.combineLatest(callForContributors, repoDisplay)
      .map { (contributors, repo) -> UIViewController in
        let vc = RepositoryContributorsTableViewController.instantiate()
        if let contributors = contributors {
          vc.set(contributors: contributors, of: repo)
        } else {
          vc.set(contributorsBelongTo: repo)
        }
        return vc
    }


    let callForStargazers = self.clickStargazersProperty.signal.filter { $0.isNil || ($0!.isEmpty == false) }
    let pushStargazersVC = Signal.combineLatest(callForStargazers, repoDisplay)
      .map { (stargazers, repo) -> UIViewController in
        let vc = RepositoryStargazersTableViewController.instantiate()
        if let stargazers = stargazers {
          vc.set(stargazers: stargazers, of: repo)
        } else {
          vc.set(stargazersBelongTo: repo)
        }
        return vc
    }

    let callForPullRequests = self.clickPullRequestsProperty.signal.filter { $0.isNil || ($0!.isEmpty == false) }
    let pushPullRequestsVC = Signal.combineLatest(callForPullRequests, repoDisplay)
      .map { (prs, repo) -> UIViewController in
        let vc = PullRequestsTableViewController.instantiate()
        if let prs = prs {
          vc.set(pullRequests: prs, of: repo)
        } else {
          vc.set(pullRequestsBelongTo: repo)
        }
        return vc
    }

    let callForIssues = self.clickIssuesProperty.signal.filter { $0.isNil || ($0!.isEmpty == false) }
    let pushIssuesVC = Signal.combineLatest(callForIssues, repoDisplay)
      .map { (issues, repo) -> UIViewController in
        let vc = RepositoryIssuesTableViewController.instantiate()
        if let issues = issues {
          vc.set(issues: issues, of: repo)
        } else {
          vc.set(issuesBelongTo: repo)
        }
        return vc
    }

    self.pushViewController = Signal.merge(pushReadmeVC,
                                           pushBranchContent,
                                           pushOwnerVC,
                                           pushForksVC,
                                           pushReleasesVC,
                                           pushActivitiesVC,
                                           pushContributorsVC,
                                           pushStargazersVC,
                                           pushPullRequestsVC,
                                           pushIssuesVC)
  }

  fileprivate let clickRepoOwnerProperty = MutableProperty<UserLite?> (nil)
  func click(repoOwner: UserLite) {
    self.clickRepoOwnerProperty.value = repoOwner
  }

  fileprivate let clickReadmeProperty = MutableProperty<Readme?>(nil)
  func click (readme: Readme?) {
    self.clickReadmeProperty.value = readme
  }

  fileprivate let clickForksProperty = MutableProperty<[Repository]?>(nil)
  func click (forks: [Repository]?) {
    self.clickForksProperty.value = forks
  }

  fileprivate let clickReleasesProperty = MutableProperty<[Release]?>(nil)
  func click (releases: [Release]?) {
    self.clickReleasesProperty.value = releases
  }

  fileprivate let clickActivitiesProperty = MutableProperty<[GHEvent]?>(nil)
  func click (activities: [GHEvent]?) {
    self.clickActivitiesProperty.value = activities
  }

  fileprivate let clickContributorsProperty = MutableProperty<[UserLite]?>(nil)
  func click (contributors: [UserLite]?) {
    self.clickContributorsProperty.value = contributors
  }

  fileprivate let clickStargazersProperty = MutableProperty<[UserLite]?>(nil)
  func click (stargazers: [UserLite]?) {
    self.clickStargazersProperty.value = stargazers
  }

  fileprivate let clickPullRequestsProperty = MutableProperty<[PullRequest]?>(nil)
  func click (pullRequests: [PullRequest]?){
    self.clickPullRequestsProperty.value = pullRequests
  }

  fileprivate let clickIssuesProperty = MutableProperty<[Issue]?>(nil)
  func click (issues: [Issue]?) {
    self.clickIssuesProperty.value = issues
  }

  fileprivate let clickBranchProperty = MutableProperty<BranchLite?>(nil)
  func click (branch: BranchLite) {
    self.clickBranchProperty.value = branch
  }

  fileprivate let clickCommitsOnBranchProperty = MutableProperty<BranchLite?>(nil)
  func clickCommits(on branch: BranchLite) {
    self.clickCommitsOnBranchProperty.value = branch
  }

  fileprivate let datasourceInitializedProperty = MutableProperty()
  public func datasourceInitialized() {
    self.datasourceInitializedProperty.value = ()
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

  internal let repository: Signal<Repository, NoError>
  internal let repoReadme: Signal<Readme?, NoError>
  internal let repoForks: Signal<[Repository], NoError>
  internal let repoReleases: Signal<[Release], NoError>
  internal let repoActivities: Signal<[GHEvent], NoError>
  internal let repoContributors: Signal<[UserLite], NoError>
  internal let repoStargazers: Signal<[UserLite], NoError>
  internal let repoPullRequests: Signal<[PullRequest], NoError>
  internal let repoIssues: Signal<[Issue], NoError>
  internal let branchLites: Signal<[BranchLite], NoError>
  internal let commits: Signal<[Commit], NoError>

  internal let pushViewController: Signal<UIViewController, NoError>
  internal let popupViewController: Signal<UIViewController, NoError>
  
  internal var inputs: RepositoryViewModelInputs { return self }
  internal var outputs: RepositoryViewModelOutputs { return self }
}
