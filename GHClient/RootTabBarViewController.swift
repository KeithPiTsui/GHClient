//
//  RootTabBarViewController.swift
//  GHClient
//
//  Created by Pi on 08/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import Prelude
import ReactiveSwift
import Result
import ReactiveCocoa

internal final class RootTabBarViewController: UITabBarController {

  fileprivate let viewModel: RootTabBarViewModelType = RootTabBarViewModel()


  override internal func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self

    NotificationCenter
      .default
      .addObserver(forName: Notification.Name.gh_userAuthenticationFailed, object: nil, queue: nil)
      { [weak self] (notification) in
        guard let error = notification.userInfo?[NotificationKeys.loginFailedError] as? ErrorEnvelope else { return }
         self?.viewModel.inputs.userAuthenticationFailed(with: error)
    }

    NotificationCenter
      .default
      .addObserver(forName: Notification.Name.appRunOnGuestMode, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.appRunOnGuestMode()
    }

    NotificationCenter
      .default
      .addObserver(forName: Notification.Name.gh_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    NotificationCenter
      .default
      .addObserver(forName: Notification.Name.gh_sessionEnded, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionEnded()
    }

    NotificationCenter
      .default
      .addObserver(forName: Notification.Name.gh_userUpdated, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.currentUserUpdated()
    }

    self.viewModel.inputs.viewDidLoad()

    AppEnvironment.authenticateCurrentAccount()
  }

  override func bindStyles() {
    super.bindStyles()
    _ = self.tabBar
      |> UITabBar.lens.tintColor .~ tabBarSelectedColor
      |> UITabBar.lens.barTintColor .~ tabBarTintColor
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.setViewControllers
      .observeForUI()
      .observeValues { [weak self] in self?.setViewControllers($0, animated: false) }

    self.viewModel.outputs.selectedIndex
      .observeForUI()
      .observeValues { [weak self] in self?.selectedIndex = $0 }


    self.viewModel.outputs.tabBarItemsData
      .observeForUI()
      .observeValues { [weak self] in self?.setTabBarItemStyles(withData: $0) }

    self.viewModel.outputs.presentAlert
      .observeForControllerAction()
      .observeValues { [weak self] in
      self?.dismiss(animated: true, completion: nil)
      self?.present($0, animated: true, completion: nil)
    }

  }

  fileprivate func setTabBarItemStyles(withData data: TabBarItemsData) {
    data.items.forEach { item in
      switch item {
      case let .discovery(index):
        _ = tabBarItem(atIndex: index) ?|> discoveryTabBarItemStyle
      case let .activity(index):
        _ = tabBarItem(atIndex: index) ?|> activityTabBarItemStyle(isLogin: data.isLoggedIn)
      case let .search(index):
        _ = tabBarItem(atIndex: index) ?|> searchTabBarItemStyle
      case let .login(index):
        _ = tabBarItem(atIndex: index) ?|> profileTabBarItemStyle(isLoggedIn: data.isLoggedIn)
      case let .profile(index):
        _ = tabBarItem(atIndex: index) ?|> profileTabBarItemStyle(isLoggedIn: data.isLoggedIn)
      }
    }
  }

  fileprivate func tabBarItem(atIndex index: Int) -> UITabBarItem? {
    if (self.tabBar.items?.count ?? 0) > index {
      if let item = self.tabBar.items?[index] {
        return item
      }
    }
    return nil
  }

}

extension RootTabBarViewController: UITabBarControllerDelegate {
  //    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
  //        if let rvc = viewController as? UINavigationController,
  //            let vc = rvc.viewControllers.first as? UserProfileViewController,
  //            let user = AppEnvironment.current.currentUser {
  //            vc.set(user: user)
  //        }
  //    }
}























