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

struct DiscoveryParams {

}

internal struct TabBarItemsData {
  internal let items: [TabBarItem]
  internal let isLoggedIn: Bool
}

internal enum TabBarItem {
  case activity(index: Int)
  case discovery(index: Int)
  case profile(index: Int)
  case search(index: Int)
  case login(index: Int)
}

internal protocol RootTabBarViewModelInputs {
  /// Call when the controller has received a user updated notification.
  func currentUserUpdated()

  /// Call when selected tab bar index changes.
  func didSelectIndex(_ index: Int)

  /// Call when we should switch to the activities tab.
  func switchToActivities()

  /// Call when we should switch to the discovery tab.
  func switchToDiscovery(params: DiscoveryParams?)

  /// Call when we should switch to the login tab.
  func switchToLogin()

  /// Call when we should switch to the profile tab.
  func switchToProfile()

  /// Call when we should switch to the search tab.
  func switchToSearch()

  /// Call when the controller has received a user session ended notification.
  func userSessionEnded()

  /// Call when the controller has received a user session started notification.
  func userSessionStarted()

  /// Call when the controller has received an app run on guest mode notification.
  func appRunOnGuestMode()

  /// Call when app failed to authenticate current user
  func userAuthenticationFailed(with error: ErrorEnvelope)

  /// Call from the controller's `viewDidLoad` method.
  func viewDidLoad()
}

internal protocol RootTabBarViewModelOutputs {
  /// Emits when the discovery VC should filter with specific params.
  //    var filterDiscovery: Signal<(UIViewController, DiscoveryParams), NoError> { get }

  /// Emits a controller that should be scrolled to the top. This requires figuring out what kind of
  /// controller it is, and setting its `contentOffset`.
  var scrollToTop: Signal<UIViewController, NoError> { get }

  /// Emits an index that the tab bar should be switched to.
  var selectedIndex: Signal<Int, NoError> { get }

  /// Emits the array of view controllers that should be set on the tab bar.
  var setViewControllers: Signal<([UIViewController],TabBarItemsData), NoError> { get }

  var presentAlert: Signal<UIAlertController, NoError> {get}
}

internal protocol RootTabBarViewModelType {
  var inputs: RootTabBarViewModelInputs { get }
  var outputs: RootTabBarViewModelOutputs { get }
}

internal final class RootTabBarViewModel:
RootTabBarViewModelType, RootTabBarViewModelInputs, RootTabBarViewModelOutputs {

  init() {
    let currentUser = Signal.merge(
      self.viewDidLoadProperty.signal,
      self.userSessionStartedProperty.signal,
      self.userSessionEndedProperty.signal,
      self.currentUserUpdatedProperty.signal
      )
      .map { AppEnvironment.current.currentUser }

    let userState: Signal<Bool, NoError> = currentUser
      .map { $0 != nil }
      .skipRepeats(==)

    let defualtViewControllers = self.viewDidLoadProperty.signal
      .map { () -> ([UIViewController],String) in ([UIViewController()],"default")}

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
      .merge(self.appRunOnGuestModeProperty.signal, self.userSessionEndedProperty.signal)
      .map { () -> ([UIViewController],String) in
        ([
          DiscoveryViewController.instantiate(),
          SearchViewController.instantiate(),
          LoginViewController.instantiate()
        ],"guest")
    }

    let viewControllers = Signal.merge(defualtViewControllers, accountModeControllers, guestModeControllers)

    self.setViewControllers = viewControllers.map{ (vcs, tag) -> ([UIViewController], TabBarItemsData) in
      (vcs, tabData(for: vcs, and: tag))
    }

    let loginState = userState
    let vcCount = self.setViewControllers.map { $0.0.count }

    let switchToLogin = Signal.combineLatest(vcCount, loginState)
      .takeWhen(self.switchToLoginProperty.signal)
      .filter { isFalse($1) }
      .map(first)

    let switchToProfile = Signal.combineLatest(vcCount, loginState)
      .takeWhen(self.switchToProfileProperty.signal)
      .filter { isTrue($1) }
      .map(first)

    self.selectedIndex =
      Signal.combineLatest(
        .merge(
          self.didSelectIndexProperty.signal,
          self.switchToActivitiesProperty.signal.mapConst(1),
          self.switchToDiscoveryProperty.signal.mapConst(0),
          self.switchToSearchProperty.signal.mapConst(2),
          switchToLogin,
          switchToProfile
        ),
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


    self.presentAlert = self.userAuthenticationFailedProperty.signal.skipNil().map{ (error) -> UIAlertController in
      let alert = UIAlertController(title: "Cannot authenticate current user",
                                    message: "Try to login again",
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
      alert.addAction(UIAlertAction(title: "Login", style: .default, handler: {_ in print("go to login")}))
      return alert
    }
  }



  fileprivate let userAuthenticationFailedProperty = MutableProperty<ErrorEnvelope?>(nil)
  internal func userAuthenticationFailed(with error: ErrorEnvelope) {
    self.userAuthenticationFailedProperty.value = error
  }

  fileprivate let appRunOnGuestModeProperty = MutableProperty(())
  internal func appRunOnGuestMode() {
    self.appRunOnGuestModeProperty.value = ()
  }

  fileprivate let currentUserUpdatedProperty = MutableProperty(())
  internal func currentUserUpdated() {
    self.currentUserUpdatedProperty.value = ()
  }
  fileprivate let didSelectIndexProperty = MutableProperty(0)
  internal func didSelectIndex(_ index: Int) {
    self.didSelectIndexProperty.value = index
  }
  fileprivate let switchToActivitiesProperty = MutableProperty()
  internal func switchToActivities() {
    self.switchToActivitiesProperty.value = ()
  }

  fileprivate let switchToDiscoveryProperty = MutableProperty<DiscoveryParams?>(nil)
  internal func switchToDiscovery(params: DiscoveryParams?) {
    self.switchToDiscoveryProperty.value = params
  }
  fileprivate let switchToLoginProperty = MutableProperty()
  internal func switchToLogin() {
    self.switchToLoginProperty.value = ()
  }
  fileprivate let switchToProfileProperty = MutableProperty()
  internal func switchToProfile() {
    self.switchToProfileProperty.value = ()
  }
  fileprivate let switchToSearchProperty = MutableProperty()
  internal func switchToSearch() {
    self.switchToSearchProperty.value = ()
  }
  fileprivate let userSessionStartedProperty = MutableProperty<()>()
  internal func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }
  fileprivate let userSessionEndedProperty = MutableProperty<()>()
  internal func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty<()>()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }


  internal let scrollToTop: Signal<UIViewController, NoError>
  internal let selectedIndex: Signal<Int, NoError>
  internal let setViewControllers: Signal<([UIViewController], TabBarItemsData), NoError>
  internal let presentAlert: Signal<UIAlertController, NoError>


  internal var inputs: RootTabBarViewModelInputs { return self }
  internal var outputs: RootTabBarViewModelOutputs { return self }
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
func == (lhs: TabBarItemsData, rhs: TabBarItemsData) -> Bool {
  return lhs.items == rhs.items &&
    lhs.isLoggedIn == rhs.isLoggedIn
}

// swiftlint:disable cyclomatic_complexity
extension TabBarItem: Equatable {}
func == (lhs: TabBarItem, rhs: TabBarItem) -> Bool {
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








































