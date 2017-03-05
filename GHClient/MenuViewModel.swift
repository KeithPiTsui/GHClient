//
//  MenuViewModel.swift
//  GHClient
//
//  Created by Pi on 02/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import GHAPI

internal protocol MenuViewModelInputs {
    
    /// Call when user tapped on the account icon
    func tappedUserIcon()
    
    /// Call when user tapped menu item
    func tappedMenuItem(_ item: MenuItem)
    
    /// Call when the view did load.
    func viewDidLoad()
    
    /// Call when the view will appear with animated property.
    func viewWillAppear(animated: Bool)
}

internal protocol MenuViewModelOutpus {
    
    /// Emit signal to change the title of view controller
    var title: Signal<String, NoError> { get }
    
    /// Emit a signal to present a view controller. E.g. user tapped user icon to login or logout
    /// Login view controller would be `LoginViewController`, whereas logout's would be an alert view controller
    var presentViewController: Signal<UIViewController, NoError> { get }
    
    /// Emit signal for new personal items
    var personalMenuItems: Signal<[MenuItem], NoError> {get}
    
    /// Emit signal for new discovery items
    var discoveryMenuItems: Signal<[MenuItem], NoError> {get}
    
    /// Emit signal for new app items
    var appMenuItems: Signal<[MenuItem], NoError> {get}
    
    /// Emit signal for going to User Profile
    var gotoUserProfile: Signal<User, NoError> {get}
    
    /// Emit signal for going to User Profile
    var gotoSearching: Signal<(), NoError> {get}
    
    /// Emit signal for going to User Profile
    var gotoSettings: Signal<(), NoError> {get}
    
    
    
}

internal protocol MenuViewModelType {
    var inputs: MenuViewModelInputs { get }
    var outpus: MenuViewModelOutpus { get }
}


internal final class MenuViewModel: MenuViewModelType, MenuViewModelInputs, MenuViewModelOutpus {
    
    init() {
        self.title = self.viewDidLoadProperty.signal.map { return "Guest"}
        
        self.presentViewController = self.tappedUserIconProperty.signal.map {
            if AppEnvironment.current.currentUser != nil {
                let alert = UIAlertController(title: "Logout", message: "Message", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                return alert
            } else {
                return UINavigationController(rootViewController: LoginViewController.instantiate())
            }
        }
        
        self.personalMenuItems = self.viewDidLoadProperty.signal
            .filter{ AppEnvironment.current.currentUser != nil }
            .map {
                return [.Personal(.UserProfile)
                    , .Personal(.PersonalRepos)
                    , .Personal(.WathcedRepos)
                    , .Personal(.StarredRepos)
                    , .Personal(.IssuesRequests)
                    , .Personal(.PersonalGists)
                    , .Personal(.StarredGists)
                    , .Personal(.Feeds)]
            }
        
        self.discoveryMenuItems = self.viewDidLoadProperty.signal.map {
            return [.Discovery(.Searching), .Discovery(.Trending)]
        }
        
        self.appMenuItems = self.viewDidLoadProperty.signal.map {
            return [.App(.Settings), .App(.Feedback)]
        }
        
        self.gotoUserProfile = self.tappedMenuItemProperty.signal.skipNil()
            .filter{if case let .Personal(x) = $0, x == .UserProfile { return true } else { return false }}
            .map {_ in
                guard let user = AppEnvironment.current.currentUser
                    else { fatalError("Only logined user can go to user profile from menu item")}
                return user }
        
        self.gotoSearching = self.tappedMenuItemProperty.signal.skipNil()
            .filter{if case let .Discovery(x) = $0, x == .Searching { return true } else { return false }}
            .map {_ in return () }
        
        self.gotoSettings = self.tappedMenuItemProperty.signal.skipNil()
            .filter{if case let .App(x) = $0, x == .Settings { return true } else { return false }}
            .map {_ in return () }
        
    }
    
    fileprivate let tappedMenuItemProperty = MutableProperty<MenuItem?>(nil)
    internal func tappedMenuItem(_ item: MenuItem) {
        self.tappedMenuItemProperty.value = item
    }
    
    fileprivate let tappedUserIconProperty = MutableProperty()
    internal func tappedUserIcon() {
        self.tappedUserIconProperty.value = ()
    }
    
    fileprivate let viewDidLoadProperty = MutableProperty()
    internal func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    fileprivate let viewWillAppearProperty = MutableProperty<Bool?>(nil)
    internal func viewWillAppear(animated: Bool) {
        self.viewWillAppearProperty.value = animated
    }
    
    internal let title: Signal<String, NoError>
    internal let presentViewController: Signal<UIViewController, NoError>
    internal let personalMenuItems: Signal<[MenuItem], NoError>
    internal let discoveryMenuItems: Signal<[MenuItem], NoError>
    internal let appMenuItems: Signal<[MenuItem], NoError>
    internal let gotoUserProfile: Signal<User, NoError>
    internal let gotoSettings: Signal<(), NoError>
    internal let gotoSearching: Signal<(), NoError>
    
    internal var inputs: MenuViewModelInputs { return self }
    internal var outpus: MenuViewModelOutpus { return self }
}


































