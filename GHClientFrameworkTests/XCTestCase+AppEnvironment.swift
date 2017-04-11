import XCTest
import AVFoundation
import Foundation
import GHAPI
import ReactiveSwift
import GHClientFramework
import Result
import TwitterImagePipeline

extension XCTestCase {

  // Pushes an environment onto the stack, executes a closure, and then pops the environment from the stack.
  func withEnvironment(_ env: Environment, body: () -> Void) {
    AppEnvironment.pushEnvironment(env)
    body()
    AppEnvironment.popEnvironment()
  }

  // Pushes an environment onto the stack, executes a closure, and then pops the environment from the stack.
  func withEnvironment(
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
    urlCacheParameters: Environment.URLCacheParameters = Environment.URLCacheParameters.defaultParameters,
    imagePipeline: TIPImagePipeline = TIPImagePipeline.defaultPipeline,
    body: () -> Void) {

    withEnvironment(
      Environment(
        apiService: apiService,
        apiDelayInterval: apiDelayInterval,
        cache: cache,
        calendar: calendar,
        cookieStorage: cookieStorage,
        countryCode: countryCode,
        currentUser: currentUser,
        dateType: dateType,
        debounceInterval: debounceInterval,
        isVoiceOverRunning: isVoiceOverRunning,
        locale: locale,
        mainBundle: mainBundle,
        reachability: reachability,
        scheduler: scheduler,
        ubiquitousStore: ubiquitousStore,
        userDefaults: userDefaults,
        urlCacheParameters: urlCacheParameters,
        imagePipeline: imagePipeline
      ),
      body: body
    )
  }
}
