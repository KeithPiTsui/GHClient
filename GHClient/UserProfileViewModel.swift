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
    
    /// Call when the user tapped reflesh button
    func tappedRefleshButton()
    
    /// Call when the user tapped event table
    func tappedEvent(eventConfig: UserProfileEventTableViewCellConfig)
}

internal protocol UserProfileViewModelOutputs {
    
    /// Emit a signal to update user avatar
    var userAvatar: Signal<UIImage, NoError> { get }
    
    /// Emit a signal to update username
    var userName: Signal<String, NoError> {get}
    
    /// Emit a signal to location
    var userLocation: Signal<String, NoError> {get}
    
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
        self.followings = self.viewWillAppearProperty.signal.map{_ in return AppEnvironment.current.currentUser?.followers ?? 0}
        self.repositories = self.viewWillAppearProperty.signal.map{_ in return AppEnvironment.current.currentUser?.publicRepos ?? 0}
        self.followers = self.viewWillAppearProperty.signal.map{_ in return AppEnvironment.current.currentUser?.following ?? 0}
        self.events = self.viewWillAppearProperty.signal.map {_ in
            guard let img = UIImage(named: "phone-icon") else { fatalError("No such image phone_icon") }
            return [(img, "RecentActivity"),(img, "Starred Repos"),(img, "Gists")]
        }
        self.organizations = self.viewWillAppearProperty.signal.map {_ in
            return [] // "A", "B", "C", "D"
        }
        self.userName = self.viewWillAppearProperty.signal.map{_ in return AppEnvironment.current.currentUser?.name ?? "unknown"}
        self.userLocation = self.viewWillAppearProperty.signal.map{_ in return AppEnvironment.current.currentUser?.location ?? "unknown"}
        self.userAvatar = self.userAvatarProperty.signal.skipNil()
        
        self.viewWillAppearProperty.signal.observe(on: QueueScheduler()).observeValues { [weak self] _ in
            guard let imgUrlStr = AppEnvironment.current.currentUser?.avatar.url,
                let imgUrl = URL(string: imgUrlStr) else { return }
            guard let imgData = try? Data(contentsOf: imgUrl) else { return }
            guard let image = UIImage(data: imgData) else { return }
            self?.userAvatarProperty.value = image
        }
        
    }
    
    fileprivate let tappedEventProperty = MutableProperty<UserProfileEventTableViewCellConfig?>(nil)
    internal func tappedEvent(eventConfig: UserProfileEventTableViewCellConfig) {
        self.tappedEventProperty.value = eventConfig
    }
    
    fileprivate let tappedRefleshButtonProperty = MutableProperty()
    internal func tappedRefleshButton() {
        self.tappedRefleshButtonProperty.value = ()
    }
    
    fileprivate let viewDidLoadProperty = MutableProperty()
    internal func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    fileprivate let viewWillAppearProperty = MutableProperty<Bool?>(nil)
    internal func viewWillAppear(animated: Bool) {
        self.viewWillAppearProperty.value = animated
    }
    
    fileprivate let userAvatarProperty = MutableProperty<UIImage?>(nil)
    
    internal let followers: Signal<Int, NoError>
    internal let followings: Signal<Int, NoError>
    internal let repositories: Signal<Int, NoError>
    internal let events: Signal<[UserProfileEventTableViewCellConfig], NoError>
    internal let organizations: Signal<[UserProfileOrganizationTableViewCellConfig], NoError>
    internal let userName: Signal<String, NoError>
    internal let userAvatar: Signal<UIImage, NoError>
    internal let userLocation: Signal<String, NoError>
    
    internal var inputs: UserProfileViewModelInputs { return self }
    internal var outputs: UserProfileViewModelOutputs { return self}
}

















