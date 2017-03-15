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

}

public protocol AppDelegateViewModelOutputs {
  /// The value to return from the delegate's `application:didFinishLaunchingWithOptions:` method.
  var applicationDidFinishLaunchingReturnValue: Bool { get }


  //    var user: Signal<User, NoError> { get }

}

public protocol AppDelegateViewModelType {
  var inputs: AppDelegateViewModelInputs {get}
  var outputs: AppDelegateViewModelOutputs {get}
}

public final class AppDelegateViewModel: AppDelegateViewModelType, AppDelegateViewModelInputs, AppDelegateViewModelOutputs {

  init() {
    //        self.user = self.applicationLaunchOptionsProperty.signal.map{ (op) -> User? in
    //                if let u = AppEnvironment.current.currentUser {
    //                    return AppEnvironment.current.apiService.user(referredBy: u.urls.url).single().map{$0.value} ?? nil
    //                }
    //                return nil
    //        }.skipNil()
  }


  fileprivate typealias ApplicationWithOptions = (application: UIApplication?, options: [AnyHashable: Any]?)
  fileprivate let applicationLaunchOptionsProperty = MutableProperty<ApplicationWithOptions?>(nil)
  public func applicationDidFinishLaunching(application: UIApplication?,
                                            launchOptions: [AnyHashable: Any]?) {
    self.applicationLaunchOptionsProperty.value = (application, launchOptions)
  }

  fileprivate let applicationDidFinishLaunchingReturnValueProperty = MutableProperty(true)
  public var applicationDidFinishLaunchingReturnValue: Bool {
    return applicationDidFinishLaunchingReturnValueProperty.value
  }

  //    public let presentViewController: Signal<UIViewController, NoError>

  //    public let user: Signal<User, NoError>

  public var inputs: AppDelegateViewModelInputs { return self }
  public var outputs: AppDelegateViewModelOutputs { return self }
}




















































