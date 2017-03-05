//
//  MainViewModel.swift
//  GHClient
//
//  Created by Pi on 02/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

internal protocol RootSplitViewModelInputs {
    
    /// Call when the controller has received a user session ended notification.
    func userSessionEnded()
    
    /// Call when the controller has received a user session started notification.
    func userSessionStarted()
    
    /// Call from the controller's `viewDidLoad` method.
    func viewDidLoad()
}

typealias MasterDetailViewContollerPair = (master: UIViewController, detail: UIViewController)

internal protocol RootSplitViewModelOutputs {
    
    /// Emits the array of view controllers that should be set on the tab bar.
    var setViewControllers: Signal<MasterDetailViewContollerPair, NoError> { get }
}

internal protocol RootSplitViewModelType {
    var inputs: RootSplitViewModelInputs { get }
    var outputs: RootSplitViewModelOutputs { get }
}

internal final class RootSplitViewModel: RootSplitViewModelType, RootSplitViewModelInputs, RootSplitViewModelOutputs {
    
    init() {
        self.setViewControllers = self.viewDidLoadProperty.signal.map{
            return (MenuViewController.instantiate(), UserProfileViewController.instantiate())
        }
    }
    
    fileprivate let userSessionStartedProperty = MutableProperty<()>()
    internal func userSessionStarted() {
        self.userSessionStartedProperty.value = ()
    }
    fileprivate let userSessionEndedProperty = MutableProperty<()>()
    internal func userSessionEnded() {
        self.userSessionEndedProperty.value = ()
    }
    
    fileprivate let viewDidLoadProperty = MutableProperty<()>()
    internal func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    internal let setViewControllers: Signal<MasterDetailViewContollerPair, NoError>
    
    
    internal var inputs: RootSplitViewModelInputs { return self }
    internal var outputs: RootSplitViewModelOutputs { return self }
}

























