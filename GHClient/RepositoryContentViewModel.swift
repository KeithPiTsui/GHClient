//
//  RepositoryContentViewModel.swift
//  GHClient
//
//  Created by Pi on 21/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import ReactiveExtensions
import GHAPI
import Prelude

internal protocol RepositoryContentViewModelInputs {

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  /// Call when vc is set with repo and branch
  func set(repo: Repository, and branch: BranchLite)

  /// Call when vc is set with content url
  func set(contentURL: URL)

  /// Call when user tapped on content
  func tapped(on content: Content)
}

internal protocol RepositoryContentViewModelOutputs {

  var contents: Signal<[Content], NoError> { get }

  var pushViewContoller: Signal<UIViewController, NoError> { get }
}

internal protocol RepositoryContentViewModelType {
  var inputs: RepositoryContentViewModelInputs { get }
  var outpus: RepositoryContentViewModelOutputs { get }
}


internal final class RepositoryContentViewModel:
  RepositoryContentViewModelType,
  RepositoryContentViewModelInputs,
RepositoryContentViewModelOutputs {

  init() {
    let content1  = Signal.combineLatest(self.setRepoAndBranchProperty.signal.skipNil(),
                                         self.viewDidLoadProperty.signal)
      .map(first)
      .map { (repo, branch) in
        return AppEnvironment.current.apiService.contents(of: repo, ref: branch.name).single()?.value}
      .skipNil()

    let content2 = Signal.combineLatest(self.setContentURLProperty.signal.skipNil(),
                                        self.viewDidLoadProperty.signal)
      .map(first)
      .map { (url) in
        return AppEnvironment.current.apiService.contents(referredBy: url).single()?.value}
      .skipNil()

    self.contents = Signal.merge(content1, content2)

    self.pushViewContoller = self.tappedOnContentProperty.signal.skipNil()
      .map { (content) -> UIViewController in
        if content.type == "file" {
          let vc = HighlighterViewController.instantiate()
          return vc
        } else {
          let vc = RepositoryContentTableViewController.instantiate()
          vc.set(contentURL:content.url)
          return vc
        }
    }
  }

  fileprivate let tappedOnContentProperty = MutableProperty<Content?>(nil)
  public func tapped(on content: Content) {
    self.tappedOnContentProperty.value = content
  }

  fileprivate let setContentURLProperty = MutableProperty<URL?>(nil)
  public func set(contentURL: URL) {
    self.setContentURLProperty.value = contentURL
  }

  fileprivate let setRepoAndBranchProperty = MutableProperty<(Repository, BranchLite)?>(nil)
  public func set(repo: Repository, and branch: BranchLite) {
    self.setRepoAndBranchProperty.value = (repo, branch)
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

  internal let contents: Signal<[Content], NoError>
  internal let pushViewContoller: Signal<UIViewController, NoError>

  internal var inputs: RepositoryContentViewModelInputs { return self }
  internal var outpus: RepositoryContentViewModelOutputs { return self }
}
