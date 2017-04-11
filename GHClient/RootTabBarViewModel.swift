//
//  RootTabBarViewModel.swift
//  GHClient
//
//  Created by Pi on 08/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import GHAPI
import Prelude

public struct TabBarItemsData {
  public let items: [TabBarItem]
  public let isLoggedIn: Bool
}

public enum TabBarItem {
  case activity(index: Int)
  case discovery(index: Int)
  case profile(index: Int)
  case search(index: Int)
  case login(index: Int)
}

public protocol RootTabBarViewModelInputs {

  /// Call when selected tab bar index changes.
  func didSelectIndex(_ index: Int)

  /// Call when the controller has received a user session started notification.
  func userSessionStarted()

  /// Call when the controller has received a user session ended notification.
  func userSessionEnded()

  /// Call when the controller has received an app run on guest mode notification.
  func appRunOnGuestMode()

  /// Call when app failed to authenticate current user
  func userAuthenticationFailed(with error: ErrorEnvelope)

  /// Call from the controller's `viewDidLoad` method.
  func viewDidLoad()

  /// Call when user click the login button on AlertController, after authentication failed
  func shouldProvideLoginView()

  /// Call when user click the Guest Mode button on AlertController, after authentication failed
  func shouldEnterGuestMode()
}

public protocol RootTabBarViewModelOutputs {

  /// Emits a controller that should be scrolled to the top. This requires figuring out what kind of
  /// controller it is, and setting its `contentOffset`.
  var scrollToTop: Signal<UIViewController, NoError> { get }

  /// Emits an index that the tab bar should be switched to.
  var selectedIndex: Signal<Int, NoError> { get }

  /// Emits the array of view controllers that should be set on the tab bar.
  var setViewControllers: Signal<([UIViewController],TabBarItemsData), NoError> { get }


  var showUserAuthenticationFailedError: Signal<ErrorEnvelope, NoError> {get}

  var showUserLoginView: Signal<(), NoError> { get }
}

public protocol RootTabBarViewModelType {
  var inputs: RootTabBarViewModelInputs { get }
  var outputs: RootTabBarViewModelOutputs { get }
}

public final class RootTabBarViewModel:
RootTabBarViewModelType, RootTabBarViewModelInputs, RootTabBarViewModelOutputs {

  init() {

    let userAuthenticationViewControllers = self.viewDidLoadProperty.signal
      .map { () -> ([UIViewController],String) in
        ([UserAuthenticationViewController.instantiate()],"default")
    }

    let accountModeControllers = self.userSessionStartedProperty.signal
      .map { () -> ([UIViewController],String) in
        ([
          DiscoveryViewController.instantiate(),
          ActivitesViewController.instantiate(),
          SearchViewController.instantiate(),
          MeTableViewController.instantiate()
        ],"account")
    }

    let guestModeControllers = Signal
      .merge(self.appRunOnGuestModeProperty.signal,
             self.userSessionEndedProperty.signal,
             self.shouldEnterGuestModeProperty.signal)
      .map { () -> ([UIViewController],String) in
        ([
          DiscoveryViewController.instantiate(),
          SearchViewController.instantiate(),
          LoginViewController.instantiate()
        ],"guest")
    }

    let viewControllers = Signal.merge(userAuthenticationViewControllers,
                                       accountModeControllers,
                                       guestModeControllers)

    self.setViewControllers = viewControllers
      .map{ (vcs, tag) -> ([UIViewController], TabBarItemsData) in
      (vcs, tabData(for: vcs, and: tag))
    }

    self.selectedIndex =
      Signal.combineLatest(
        .merge(self.didSelectIndexProperty.signal),
        self.setViewControllers.map(first),
        self.viewDidLoadProperty.signal)
        .map { idx, vcs, _ in clamp(0, vcs.count - 1)(idx) }

    let selectedTabAgain = self.selectedIndex.combinePrevious()
      .map { prev, next -> Int? in prev == next ? next : nil }
      .skipNil()

    self.scrollToTop = self.setViewControllers
      .map(first)
      .takePairWhen(selectedTabAgain)
      .map { vcs, idx in vcs[idx] }

    self.showUserAuthenticationFailedError = self.userAuthenticationFailedProperty.signal.skipNil()

    self.showUserLoginView = self.shouldProvideLoginViewProperty.signal
  }

  fileprivate let shouldProvideLoginViewProperty = MutableProperty()
  public func shouldProvideLoginView() {
    shouldProvideLoginViewProperty.value = ()
  }

  fileprivate let shouldEnterGuestModeProperty = MutableProperty()
  public func shouldEnterGuestMode() {
    self.shouldEnterGuestModeProperty.value = ()
  }

  fileprivate let userAuthenticationFailedProperty = MutableProperty<ErrorEnvelope?>(nil)
  public func userAuthenticationFailed(with error: ErrorEnvelope) {
    self.userAuthenticationFailedProperty.value = error
  }

  fileprivate let appRunOnGuestModeProperty = MutableProperty(())
  public func appRunOnGuestMode() {
    self.appRunOnGuestModeProperty.value = ()
  }

  fileprivate let didSelectIndexProperty = MutableProperty(0)
  public func didSelectIndex(_ index: Int) {
    self.didSelectIndexProperty.value = index
  }

  fileprivate let userSessionStartedProperty = MutableProperty<()>()
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }
  fileprivate let userSessionEndedProperty = MutableProperty<()>()
  public func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty<()>()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let showUserAuthenticationFailedError: Signal<ErrorEnvelope, NoError>
  public let showUserLoginView: Signal<(), NoError>
  public let scrollToTop: Signal<UIViewController, NoError>
  public let selectedIndex: Signal<Int, NoError>
  public let setViewControllers: Signal<([UIViewController], TabBarItemsData), NoError>


  public var inputs: RootTabBarViewModelInputs { return self }
  public var outputs: RootTabBarViewModelOutputs { return self }
}

private func tabData(for controllers: [UIViewController], and tag: String) -> TabBarItemsData {
  let items: [TabBarItem]
  if tag == "default" {
    items = [.discovery(index:0)]}
  else if tag == "account" {
    items = [.discovery(index:0), .activity(index:1), .search(index: 2), .profile(index: 3)]}
  else {
    items = [.discovery(index:0), .search(index: 1), .login(index: 2)]
  }
  return TabBarItemsData(items: items, isLoggedIn: false)
}

extension TabBarItemsData: Equatable {}
public func == (lhs: TabBarItemsData, rhs: TabBarItemsData) -> Bool {
  return lhs.items == rhs.items &&
    lhs.isLoggedIn == rhs.isLoggedIn
}

// swiftlint:disable cyclomatic_complexity
extension TabBarItem: Equatable {}
public func == (lhs: TabBarItem, rhs: TabBarItem) -> Bool {
  switch (lhs, rhs) {
  case let (.activity(lhs), .activity(rhs)):
    return lhs == rhs
  case let (.discovery(lhs), .discovery(rhs)):
    return lhs == rhs
  case let (.profile(lhs), .profile(rhs)):
    return lhs == rhs
  case let (.search(lhs), .search(rhs)):
    return lhs == rhs
  default: return false
  }
}
// swiftlint:enable cyclomatic_complexity

private func first<VC: UIViewController>(_ viewController: VC.Type) -> ([UIViewController]) -> VC? {
  return { viewControllers in
    viewControllers
      .index { $0 is VC }
      .flatMap { viewControllers[$0] as? VC }
  }
}








































