//
//  AppDelegate.swift
//  GHClient
//
//  Created by Pi on 28/02/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import TwitterImagePipeline
import GHClientFramework

@UIApplicationMain
internal final class AppDelegate: UIResponder, UIApplicationDelegate {

  fileprivate let viewModel: AppDelegateViewModelType = AppDelegateViewModel()
  var window: UIWindow?

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    AppEnvironment.initialize()

    /// Retrieve stored environment states if exists
    AppEnvironment.replaceCurrentEnvironment(
      AppEnvironment.fromStorage(
        ubiquitousStore: NSUbiquitousKeyValueStore.default(),
        userDefaults: UserDefaults.standard))
    
    let urlCacheParameters = AppEnvironment.current.urlCacheParameters
    URLCache.shared = URLCache(memoryCapacity: Int(urlCacheParameters.memoryCacheSize),
                               diskCapacity: Int(urlCacheParameters.diskCacheSize),
                               diskPath: urlCacheParameters.filePathForDiskCache)

    let tipConfig = TIPGlobalConfiguration.sharedInstance()
    tipConfig.serializeCGContextAccess = true
    tipConfig.isClearMemoryCachesOnApplicationBackgroundEnabled = true

    self.bindViewModel()
    self.viewModel.inputs.applicationDidFinishLaunching(application: application, launchOptions: launchOptions)

    return self.viewModel.outputs.applicationDidFinishLaunchingReturnValue
  }
  private func bindViewModel() {

  }
}






