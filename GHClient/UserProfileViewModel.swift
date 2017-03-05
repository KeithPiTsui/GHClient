//
//  UserProfileViewModel.swift
//  GHClient
//
//  Created by Pi on 05/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

internal protocol UserProfileViewModelInputs {
    
    /// Call when the view did load.
    func viewDidLoad()
    
    /// Call when the view will appear with animated property.
    func viewWillAppear(animated: Bool)
}

internal protocol UserProfileViewModelOutputs {
    
    /// Emit a signal to update followers
    var followers: Signal<Int,NoError> {get}
    
    /// Emit a signal to update repositories
    var repositories: Signal<Int, NoError> {get}
    
    /// Emit a signal to update followings
    var followings: Signal<Int, NoError> {get}
    
    /// Emit a signal to update event table
    var events: Signal<[UserProfileEventTableViewCellConfig], NoError> { get}
    
    /// Emit a signal to update organization table
    var organizations: Signal<[UserProfileOrganizationTableViewCellConfig], NoError> {get}
    
}

internal protocol UserProfileViewModelType {
    var inputs: UserProfileViewModelInputs {get}
    var outputs: UserProfileViewModelOutputs {get}
}

internal final class UserProfileViewModel: UserProfileViewModelType, UserProfileViewModelInputs, UserProfileViewModelOutputs {
    
    init() {
        self.followings = self.viewWillAppearProperty.signal.map{_ in return 1}
        self.repositories = self.viewWillAppearProperty.signal.map{_ in return 1}
        self.followers = self.viewWillAppearProperty.signal.map{_ in return 1}
        self.events = self.viewWillAppearProperty.signal.map {_ in
            guard let img = UIImage(named: "phone-icon") else { fatalError("No such image phone_icon") }
            return [(img, "RecentActivity"),(img, "Starred Repos"),(img, "Gists")]
        }
        self.organizations = self.viewWillAppearProperty.signal.map {_ in
            return [] // "A", "B", "C", "D"
        }
    }
    
    fileprivate let viewDidLoadProperty = MutableProperty()
    internal func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    fileprivate let viewWillAppearProperty = MutableProperty<Bool?>(nil)
    internal func viewWillAppear(animated: Bool) {
        self.viewWillAppearProperty.value = animated
    }
    
    internal let followers: Signal<Int, NoError>
    internal let followings: Signal<Int, NoError>
    internal let repositories: Signal<Int, NoError>
    internal let events: Signal<[UserProfileEventTableViewCellConfig], NoError>
    internal let organizations: Signal<[UserProfileOrganizationTableViewCellConfig], NoError>
    
    internal var inputs: UserProfileViewModelInputs { return self }
    internal var outputs: UserProfileViewModelOutputs { return self}
}

















