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

internal protocol MenuViewModelInputs {
    
    /// Call when user tapped on the account icon
    func tappedUserIcon()
    
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
    
}

internal protocol MenuViewModelType {
    var inputs: MenuViewModelInputs { get }
    var outpus: MenuViewModelOutpus { get }
}

internal final class MenuViewModel: MenuViewModelType, MenuViewModelInputs, MenuViewModelOutpus {
    
    init() {
        self.title = self.viewDidLoadProperty.signal.map {
            return "Guest"
        }
        
        self.presentViewController = self.tappedUserIconProperty.signal.map {
            if AppEnvironment.current.currentUser != nil {
                return LoginViewController.instantiate()
            } else {
                let alert = UIAlertController(title: "Logout", message: "Message", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                return alert
            }
        }
        
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
    
    internal var inputs: MenuViewModelInputs { return self }
    internal var outpus: MenuViewModelOutpus { return self }
}


































