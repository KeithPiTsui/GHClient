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
import GHAPI
import Prelude

internal protocol UserProfileViewModelInputs {
    
    /// Call when the view did load.
    func viewDidLoad()
    
    /// Call when the view will appear with animated property.
    func viewWillAppear(animated: Bool)
    
    /// Call when the user tapped reflesh button
    func tappedRefleshButton()
    
    /// Call when the user tapped event table
    func tappedEvent(eventConfig: UserProfileEventTableViewCellConfig)
    
    /// Call when vc receive a user to display
    func set(user: User)
    
    /// Call when vc receive a url refer to user then in turn to display
    func set(userUrl: URL)
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
        let user1 = self.setUserUrlProperty.signal.skipNil()
            .map {AppEnvironment.current.apiService.user(referredBy: $0).single()}
            .map {$0?.value}.skipNil()
        let user2 = self.setUserProperty.signal.skipNil()
        let user = Signal.merge(user1, user2)
        let userDisplay = Signal.combineLatest(user, self.viewDidLoadProperty.signal).map(first)
        
        self.followers = userDisplay.map{ return $0.followers ?? 0}
        self.repositories = userDisplay.map{$0.publicRepos ?? 0}
        self.followings = userDisplay.map{$0.following ?? 0}
        self.userName = userDisplay.map{$0.name ?? "unknown"}
        self.userLocation = userDisplay.map{$0.location ?? "unknown"}
        
        self.userAvatar = userDisplay.observe(on: QueueScheduler()).map{ (u) -> UIImage? in
            let urlStr = u.avatar.url
            guard let url = URL(string: urlStr),
                let imgData = try? Data(contentsOf: url),
                let image = UIImage(data: imgData)else { return nil }
            return image
        }.skipNil()
        
        self.events = self.viewWillAppearProperty.signal.map {_ in
            guard let img = UIImage(named: "phone-icon") else { fatalError("No such image phone_icon") }
            return [(img, "RecentActivity"),(img, "Starred Repos"),(img, "Gists")]
        }
        self.organizations = self.viewWillAppearProperty.signal.map {_ in
            return [] // "A", "B", "C", "D"
        }
    }
    
    fileprivate let setUserProperty = MutableProperty<User?>(nil)
    internal func set(user: User) {
        self.setUserProperty.value = user
    }
    
    fileprivate let setUserUrlProperty = MutableProperty<URL?>(nil)
    internal func set(userUrl: URL) {
        self.setUserUrlProperty.value = userUrl
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

















