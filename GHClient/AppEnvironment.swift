//
//  AppEnvironment.swift
//  GHClient
//
//  Created by Pi on 02/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import Argo
import Runes
import Foundation
import GHAPI
import Prelude
import ReactiveSwift
import Result

/**
 A global stack that captures the current state of global objects that the app wants access to.
 */
public struct AppEnvironment {
    internal static let environmentStorageKey = "com.kickstarter.AppEnvironment.current"
    internal static let oauthTokenStorageKey = "com.kickstarter.AppEnvironment.oauthToken"
    
    /**
     A global stack of environments.
     */
    fileprivate static var stack: [Environment] = [Environment()]
    
    /**
     Invoke when an access token has been acquired and you want to log the user in. Replaces the current
     environment with a new one that has the authenticated api service and current user model.
     
     - parameter envelope: An access token envelope with the api access token and user.
     */
//    public static func login(_ envelope: AccessTokenEnvelope) {
//        replaceCurrentEnvironment(
//            apiService: current.apiService.login(OauthToken(token: envelope.accessToken)),
//            currentUser: envelope.user
//        )
//    }
    
    /**
     Invoke when we have acquired a fresh current user and you want to replace the current environment's
     current user with the fresh one.
     
     - parameter user: A user model.
     */
    public static func updateCurrentUser(_ user: User) {
        replaceCurrentEnvironment(
            currentUser: user
        )
    }
    
//    public static func updateConfig(_ config: Config) {
//        replaceCurrentEnvironment(
//            config: config
//        )
//    }
    
    // Invoke when you want to end the user's session.
    public static func logout() {
        let storage = AppEnvironment.current.cookieStorage
        storage.cookies?.forEach(storage.deleteCookie)
        
        replaceCurrentEnvironment(
            apiService: AppEnvironment.current.apiService.logout(),
            cache: type(of: AppEnvironment.current.cache).init(),
            currentUser: nil
        )
    }
    
    // The most recent environment on the stack.
    public static var current: Environment! { return stack.last }
    
    // Push a new environment onto the stack.
    public static func pushEnvironment(_ env: Environment) {
        saveEnvironment(environment: env, ubiquitousStore: env.ubiquitousStore, userDefaults: env.userDefaults)
        stack.append(env)
    }
    
    // Pop an environment off the stack.
    @discardableResult
    public static func popEnvironment() -> Environment? {
        let last = stack.popLast()
        let next = current ?? Environment()
        saveEnvironment(environment: next,
                        ubiquitousStore: next.ubiquitousStore,
                        userDefaults: next.userDefaults)
        return last
    }
    
    // Replace the current environment with a new environment.
    public static func replaceCurrentEnvironment(_ env: Environment) {
        pushEnvironment(env)
        stack.remove(at: stack.count - 2)
    }
    
    // Pushes a new environment onto the stack that changes only a subset of the current global dependencies.
    public static func pushEnvironment(
        apiService: ServiceType = AppEnvironment.current.apiService,
        apiDelayInterval: DispatchTimeInterval = AppEnvironment.current.apiDelayInterval,
        cache: KSCache = AppEnvironment.current.cache,
        calendar: Calendar = AppEnvironment.current.calendar,
        cookieStorage: HTTPCookieStorageProtocol = AppEnvironment.current.cookieStorage,
        countryCode: String = AppEnvironment.current.countryCode,
        currentUser: User? = AppEnvironment.current.currentUser,
        dateType: DateProtocol.Type = AppEnvironment.current.dateType,
        debounceInterval: DispatchTimeInterval = AppEnvironment.current.debounceInterval,
        isVoiceOverRunning: @escaping (() -> Bool) = AppEnvironment.current.isVoiceOverRunning,
        locale: Locale = AppEnvironment.current.locale,
        mainBundle: NSBundleType = AppEnvironment.current.mainBundle,
        reachability: SignalProducer<Reachability, NoError> = AppEnvironment.current.reachability,
        scheduler: DateSchedulerProtocol = AppEnvironment.current.scheduler,
        ubiquitousStore: KeyValueStoreType = AppEnvironment.current.ubiquitousStore,
        userDefaults: KeyValueStoreType = AppEnvironment.current.userDefaults) {
        
        pushEnvironment(
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
                userDefaults: userDefaults
            )
        )
    }
    
    // Replaces the current environment onto the stack with an environment that changes only a subset
    // of current global dependencies.
    public static func replaceCurrentEnvironment(
        apiService: ServiceType = AppEnvironment.current.apiService,
        apiDelayInterval: DispatchTimeInterval = AppEnvironment.current.apiDelayInterval,
        cache: KSCache = AppEnvironment.current.cache,
        calendar: Calendar = AppEnvironment.current.calendar,
        cookieStorage: HTTPCookieStorageProtocol = AppEnvironment.current.cookieStorage,
        countryCode: String = AppEnvironment.current.countryCode,
        currentUser: User? = AppEnvironment.current.currentUser,
        dateType: DateProtocol.Type = AppEnvironment.current.dateType,
        debounceInterval: DispatchTimeInterval = AppEnvironment.current.debounceInterval,
        isVoiceOverRunning: @escaping (() -> Bool) = AppEnvironment.current.isVoiceOverRunning,
        locale: Locale = AppEnvironment.current.locale,
        mainBundle: NSBundleType = AppEnvironment.current.mainBundle,
        reachability: SignalProducer<Reachability, NoError> = AppEnvironment.current.reachability,
        scheduler: DateSchedulerProtocol = AppEnvironment.current.scheduler,
        ubiquitousStore: KeyValueStoreType = AppEnvironment.current.ubiquitousStore,
        userDefaults: KeyValueStoreType = AppEnvironment.current.userDefaults) {
        
        replaceCurrentEnvironment(
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
                userDefaults: userDefaults
            )
        )
    }
    
    // Returns the last saved environment from user defaults.
    // swiftlint:disable function_body_length
    public static func fromStorage(ubiquitousStore: KeyValueStoreType,
                                   userDefaults: KeyValueStoreType) -> Environment {
        
        let data = userDefaults.dictionary(forKey: environmentStorageKey) ?? [:]
        
        var service = current.apiService
        var currentUser: User? = nil
        
        
        if let oauthToken = data["apiService.oauthToken.token"] as? String {
            // If there is an oauth token stored in the defaults, then we can authenticate our api service
            service = service.login(OauthToken(token: oauthToken))
            removeLegacyOauthToken(fromUserDefaults: userDefaults)
        } else if let oauthToken = legacyOauthToken(forUserDefaults: userDefaults) {
            // Otherwise if there is a token in the legacy user defaults entry we can use that
            service = service.login(OauthToken(token: oauthToken))
            removeLegacyOauthToken(fromUserDefaults: userDefaults)
        }
        
        // Try restoring the client id for the api service
        if let clientId = data["apiService.serverConfig.apiClientAuth.clientId"] as? String {
            service = Service(
                serverConfig: ServerConfig(
                    apiBaseUrl: service.serverConfig.apiBaseUrl,
                    webBaseUrl: service.serverConfig.webBaseUrl,
                    apiClientAuth: ClientAuth(clientId: clientId),
                    basicHTTPAuth: service.serverConfig.basicHTTPAuth
                ),
                oauthToken: service.oauthToken
            )
        }
        
        // Try restoring the base urls for the api service
        if let apiBaseUrlString = data["apiService.serverConfig.apiBaseUrl"] as? String,
            let apiBaseUrl = URL(string: apiBaseUrlString),
            let webBaseUrlString = data["apiService.serverConfig.webBaseUrl"] as? String,
            let webBaseUrl = URL(string: webBaseUrlString) {
            
            service = Service(
                serverConfig: ServerConfig(
                    apiBaseUrl: apiBaseUrl,
                    webBaseUrl: webBaseUrl,
                    apiClientAuth: service.serverConfig.apiClientAuth,
                    basicHTTPAuth: service.serverConfig.basicHTTPAuth
                ),
                oauthToken: service.oauthToken
            )
        }
        
        // Try restoring the basic auth data for the api service
        if let username = data["apiService.serverConfig.basicHTTPAuth.username"] as? String,
            let password = data["apiService.serverConfig.basicHTTPAuth.password"] as? String {
            
            service = Service(
                serverConfig: ServerConfig(
                    apiBaseUrl: service.serverConfig.apiBaseUrl,
                    webBaseUrl: service.serverConfig.webBaseUrl,
                    apiClientAuth: service.serverConfig.apiClientAuth,
                    basicHTTPAuth: BasicHTTPAuth(username: username, password: password)
                ),
                oauthToken: service.oauthToken
                
            )
        }
        
        // Try restore the current user
        if service.oauthToken != nil {
            currentUser = data["currentUser"].flatMap(decode)
        }
        
        return Environment(
            apiService: service,
            currentUser: currentUser
        )
    }
    // swiftlint:enable function_body_length
    
    // Saves some key data for the current environment
    internal static func saveEnvironment(environment env: Environment = AppEnvironment.current,
                                         ubiquitousStore: KeyValueStoreType,
                                         userDefaults: KeyValueStoreType) {
        
        var data: [String:Any] = [:]
        
        data["apiService.oauthToken.token"] = env.apiService.oauthToken?.token
        data["apiService.serverConfig.apiBaseUrl"] = env.apiService.serverConfig.apiBaseUrl.absoluteString
        // swiftlint:disable line_length
        data["apiService.serverConfig.apiClientAuth.clientId"] = env.apiService.serverConfig.apiClientAuth.clientId
        data["apiService.serverConfig.basicHTTPAuth.username"] = env.apiService.serverConfig.basicHTTPAuth?.username
        data["apiService.serverConfig.basicHTTPAuth.password"] = env.apiService.serverConfig.basicHTTPAuth?.password
        // swiftlint:enable line_length
        data["apiService.serverConfig.webBaseUrl"] = env.apiService.serverConfig.webBaseUrl.absoluteString
        data["apiService.language"] = env.apiService.language
        data["currentUser"] = env.currentUser?.encode()
        
        userDefaults.set(data, forKey: environmentStorageKey)
    }
}

private func legacyOauthToken(forUserDefaults userDefaults: KeyValueStoreType) -> String? {
    return userDefaults.object(forKey: "com.kickstarter.access_token") as? String
}

private func removeLegacyOauthToken(fromUserDefaults userDefaults: KeyValueStoreType) {
    userDefaults.removeObjectForKey("com.kickstarter.access_token")
}
