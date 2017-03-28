//
//  AppDelegate.swift
//  GHClient
//
//  Created by Pi on 28/02/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

@UIApplicationMain
internal final class AppDelegate: UIResponder, UIApplicationDelegate {

  fileprivate let viewModel: AppDelegateViewModelType = AppDelegateViewModel()
  var window: UIWindow?

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    URLCache.shared = URLCache(memoryCapacity: 8 * 1024 * 1024,
                               diskCapacity: 20 * 1024 * 1024,
                               diskPath: "GHClientURLCache")

    /// Retrieve stored environment states if exists
    AppEnvironment.replaceCurrentEnvironment(
      AppEnvironment.fromStorage(
        ubiquitousStore: NSUbiquitousKeyValueStore.default(),
        userDefaults: UserDefaults.standard))

    self.bindViewModel()
    self.viewModel.inputs.applicationDidFinishLaunching(application: application, launchOptions: launchOptions)

    return self.viewModel.outputs.applicationDidFinishLaunchingReturnValue
  }
  private func bindViewModel() {

  }
}
