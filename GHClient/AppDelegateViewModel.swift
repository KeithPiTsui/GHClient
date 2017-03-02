//
//  AppDelegateViewModel.swift
//  GHClient
//
//  Created by Pi on 02/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import GHAPI


public protocol AppDelegateViewModelInputs {
    
    /// Call when the application finishes launching.
    func applicationDidFinishLaunching(application: UIApplication?, launchOptions: [AnyHashable: Any]?)
    
//    /// Call when the application will enter foreground.
//    func applicationWillEnterForeground()
//    
//    /// Call when the application enters background.
//    func applicationDidEnterBackground()
//    
//    /// Call when the aplication receives memory warning from the system.
//    func applicationDidReceiveMemoryWarning()
//    
//    /// Call to open a url that was sent to the app
//    func applicationOpenUrl(application: UIApplication?, url: URL, sourceApplication: String?,
//                            annotation: Any) -> Bool
//    
//    /// Call after having invoked AppEnvironemt.updateCurrentUser with a fresh user.
//    func currentUserUpdatedInEnvironment()
//    
//    /// Call when the controller has received a user session ended notification.
//    func userSessionEnded()
//    
//    /// Call when the controller has received a user session started notification.
//    func userSessionStarted()
}

public protocol AppDelegateViewModelOutputs {
    /// The value to return from the delegate's `application:didFinishLaunchingWithOptions:` method.
    var applicationDidFinishLaunchingReturnValue: Bool { get }
//
//    /// Return this value in the delegate method.
//    var continueUserActivityReturnValue: MutableProperty<Bool> { get }
//    
//    /// Emits when opening the app with an invalid access token.
//    var forceLogout: Signal<(), NoError> { get }
//    
//    /// Emits when the root view controller should navigate to activity.
//    var goToActivity: Signal<(), NoError> { get }
//    
//    /// Emits when the root view controller should navigate to the login screen.
//    var goToLogin: Signal<(), NoError> { get }
//    
//    /// Emits when the root view controller should navigate to the user's profile.
//    var goToProfile: Signal<(), NoError> { get }
//    
//    /// Emits when the root view controller should navigate to search.
//    var goToSearch: Signal<(), NoError> { get }
//    
//    /// Emits an Notification that should be immediately posted.
//    var postNotification: Signal<Notification, NoError> { get }
//    
//    /// Emits a message when a remote notification alert should be displayed to the user.
//    var presentRemoteNotificationAlert: Signal<String, NoError> { get }
//    
//    /// Emits when a view controller should be presented.
//    var presentViewController: Signal<UIViewController, NoError> { get }
//    
//    /// Emits when we should attempt registering the user for notifications.
//    var registerUserNotificationSettings: Signal<(), NoError> { get }
//    
//    /// Emits when we should unregister the user from notifications.
//    var unregisterForRemoteNotifications: Signal<(), NoError> { get }
//    
//    /// Emits a fresh user to be updated in the app environment.
//    var updateCurrentUserInEnvironment: Signal<User, NoError> { get }
}

public protocol AppDelegateViewModelType {
    var inputs: AppDelegateViewModelInputs {get}
    var outputs: AppDelegateViewModelOutputs {get}
}

public final class AppDelegateViewModel: AppDelegateViewModelType, AppDelegateViewModelInputs, AppDelegateViewModelOutputs {
    
    init() {
        
    }

    
    fileprivate typealias ApplicationWithOptions = (application: UIApplication?, options: [AnyHashable: Any]?)
    fileprivate let applicationLaunchOptionsProperty = MutableProperty<ApplicationWithOptions?>(nil)
    public func applicationDidFinishLaunching(application: UIApplication?,
                                              launchOptions: [AnyHashable: Any]?) {
        self.applicationLaunchOptionsProperty.value = (application, launchOptions)
    }
//
//    fileprivate let applicationWillEnterForegroundProperty = MutableProperty()
//    public func applicationWillEnterForeground() {
//        self.applicationWillEnterForegroundProperty.value = ()
//    }
//    
//    fileprivate let applicationDidEnterBackgroundProperty = MutableProperty()
//    public func applicationDidEnterBackground() {
//        self.applicationDidEnterBackgroundProperty.value = ()
//    }
//    
//    fileprivate let applicationDidReceiveMemoryWarningProperty = MutableProperty()
//    public func applicationDidReceiveMemoryWarning() {
//        self.applicationDidReceiveMemoryWarningProperty.value = ()
//    }
//    
//    fileprivate let currentUserUpdatedInEnvironmentProperty = MutableProperty()
//    public func currentUserUpdatedInEnvironment() {
//        self.currentUserUpdatedInEnvironmentProperty.value = ()
//    }
//    
//    
//    fileprivate let remoteNotificationAndIsActiveProperty = MutableProperty<([AnyHashable: Any], Bool)?>(nil)
//    public func didReceive(remoteNotification notification: [AnyHashable: Any], applicationIsActive: Bool) {
//        self.remoteNotificationAndIsActiveProperty.value = (notification, applicationIsActive)
//    }
//    
//    
//    fileprivate typealias ApplicationOpenUrl = (
//        application: UIApplication?,
//        url: URL,
//        sourceApplication: String?,
//        annotation: Any
//    )
//    fileprivate let applicationOpenUrlProperty = MutableProperty<ApplicationOpenUrl?>(nil)
//    public func applicationOpenUrl(application: UIApplication?,
//                                   url: URL,
//                                   sourceApplication: String?,
//                                   annotation: Any) -> Bool {
//        self.applicationOpenUrlProperty.value = (application, url, sourceApplication, annotation)
//        return self.facebookOpenURLReturnValue.value
//    }
//    
//    fileprivate let openRemoteNotificationTappedOkProperty = MutableProperty()
//    public func openRemoteNotificationTappedOk() {
//        self.openRemoteNotificationTappedOkProperty.value = ()
//    }
//    
//    fileprivate let userSessionEndedProperty = MutableProperty()
//    public func userSessionEnded() {
//        self.userSessionEndedProperty.value = ()
//    }
//    
//    fileprivate let userSessionStartedProperty = MutableProperty()
//    public func userSessionStarted() {
//        self.userSessionStartedProperty.value = ()
//    }
//    
//    fileprivate let applicationDidFinishLaunchingReturnValueProperty = MutableProperty(true)
//    public var applicationDidFinishLaunchingReturnValue: Bool {
//        return applicationDidFinishLaunchingReturnValueProperty.value
//    }
//    
//    public let forceLogout: Signal<(), NoError>
//    public let goToActivity: Signal<(), NoError>
//    
//    
//    public let goToLogin: Signal<(), NoError>
//    public let goToProfile: Signal<(), NoError>
//    public let goToSearch: Signal<(), NoError>
//    public let postNotification: Signal<Notification, NoError>
//    public let presentRemoteNotificationAlert: Signal<String, NoError>
//    public let presentViewController: Signal<UIViewController, NoError>
//    public let pushTokenSuccessfullyRegistered: Signal<(), NoError>
//    public let registerUserNotificationSettings: Signal<(), NoError>
//    public let synchronizeUbiquitousStore: Signal<(), NoError>
//    public let unregisterForRemoteNotifications: Signal<(), NoError>
//    public let updateCurrentUserInEnvironment: Signal<User, NoError>
//   
    
    fileprivate let applicationDidFinishLaunchingReturnValueProperty = MutableProperty(true)
    public var applicationDidFinishLaunchingReturnValue: Bool {
        return applicationDidFinishLaunchingReturnValueProperty.value
    }
    
    
    public var inputs: AppDelegateViewModelInputs { return self }
    public var outputs: AppDelegateViewModelOutputs { return self }
}




















































