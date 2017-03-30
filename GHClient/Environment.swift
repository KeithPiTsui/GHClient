//
//  Environment.swift
//  GHClient
//
//  Created by Pi on 02/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import Foundation
import GHAPI
import ReactiveSwift
import Result


/**
 A collection of **all** global variables and singletons that the app wants access to.
 */
public struct Environment {
  public struct URLCacheParameters {
    public let memoryCacheSize: UInt
    public let diskCacheSize: UInt
    public let filePathForDiskCache: String?

    public static var defaultParameters: URLCacheParameters {
      return URLCacheParameters(memoryCacheSize: 8 * 1024 * 1024,
                                diskCacheSize: 20 * 1024 * 1025,
                                filePathForDiskCache: nil)
    }
  }

  /// A type that exposes endpoints for fetching github data.
  public let apiService: ServiceType

  /// The amount of time to delay API requests by. Used primarily for testing. Default value is `0.0`.
  public let apiDelayInterval: DispatchTimeInterval

  /// A type that stores a cached dictionary.
  public let cache: KSCache

  /// The user's calendar.
  public let calendar: Calendar

  /// A type that exposes how to interact with cookie storage. Default value is `HTTPCookieStorage.shared`.
  public let cookieStorage: HTTPCookieStorageProtocol

  /// The user’s current country. This is valid whether the user is logged-in or not.
  public let countryCode: String

  /// The currently logged in user.
  public let currentUser: User?

  /// A type that exposes how to capture dates as measured from # of seconds since 1970.
  public let dateType: DateProtocol.Type

  /// The amount of time to debounce signals by. Default value is `0.3`.
  public let debounceInterval: DispatchTimeInterval

  /// A function that returns whether voice over mode is running.
  public let isVoiceOverRunning: () -> Bool

  /// The user’s current locale, which determines how numbers are formatted. Default value is
  /// `Locale.current`.
  public let locale: Locale

  /// A type that exposes how to interface with an NSBundle. Default value is `Bundle.main`.
  public let mainBundle: NSBundleType

  /// A reachability signal producer.
  public let reachability: SignalProducer<Reachability, NoError>

  /// A scheduler to use for all time-based RAC operators. Default value is
  /// `QueueScheduler.mainQueueScheduler`.
  public let scheduler: DateSchedulerProtocol

  /// A ubiquitous key-value store. Default value is `NSUbiquitousKeyValueStore.default`.
  public let ubiquitousStore: KeyValueStoreType

  /// A user defaults key-value store. Default value is `NSUserDefaults.standard`.
  public let userDefaults: KeyValueStoreType

  public let urlCacheParameters: URLCacheParameters

  public enum AppMode {
    case guest
    case account
  }

  /// A type that specify this mode this app should run in. Default is unknown mode
  public var appMode: Environment.AppMode {
    return self.currentUser != nil
      ? .account
      : .guest
  }

  public init(
    apiService: ServiceType = Service(),
    apiDelayInterval: DispatchTimeInterval = .seconds(0),
    cache: KSCache = KSCache(),
    calendar: Calendar = .current,
    cookieStorage: HTTPCookieStorageProtocol = HTTPCookieStorage.shared,
    countryCode: String = "US",
    currentUser: User? = nil,
    dateType: DateProtocol.Type = Date.self,
    debounceInterval: DispatchTimeInterval = .milliseconds(300),
    isVoiceOverRunning: @escaping () -> Bool = UIAccessibilityIsVoiceOverRunning,
    locale: Locale = .current,
    mainBundle: NSBundleType = Bundle.main,
    reachability: SignalProducer<Reachability, NoError> = Reachability.signalProducer,
    scheduler: DateSchedulerProtocol = QueueScheduler.main,
    ubiquitousStore: KeyValueStoreType = NSUbiquitousKeyValueStore.default(),
    userDefaults: KeyValueStoreType = UserDefaults.standard,
    urlCacheParameters: URLCacheParameters = URLCacheParameters.defaultParameters) {

    self.apiService = apiService
    self.apiDelayInterval = apiDelayInterval
    self.cache = cache
    self.calendar = calendar
    self.cookieStorage = cookieStorage
    self.countryCode = countryCode
    self.currentUser = currentUser
    self.dateType = dateType
    self.debounceInterval = debounceInterval
    self.isVoiceOverRunning = isVoiceOverRunning
    self.locale = locale
    self.mainBundle = mainBundle
    self.reachability = reachability
    self.scheduler = scheduler
    self.ubiquitousStore = ubiquitousStore
    self.userDefaults = userDefaults
    self.urlCacheParameters = urlCacheParameters
  }
}
