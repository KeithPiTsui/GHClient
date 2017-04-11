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
import TwitterImagePipeline

public protocol UserProfileViewModelInputs {

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

public protocol UserProfileViewModelOutputs {

  /// Emit a signal to update user avatar
  var userAvatar: Signal<UIImage, NoError> { get }

  /// Emit a signal to update event table
  var events: Signal<[UserProfileEventTableViewCellConfig], NoError> { get}

  /// Emit a signal to update organization table
  var organizations: Signal<[UserProfileOrganizationTableViewCellConfig], NoError> {get}

  /// Emit a signal to specify a user
  var user: Signal<User, NoError> {get}
}

public protocol UserProfileViewModelType {
  var inputs: UserProfileViewModelInputs {get}
  var outputs: UserProfileViewModelOutputs {get}
}

public final class UserProfileViewModel: UserProfileViewModelType, UserProfileViewModelInputs, UserProfileViewModelOutputs {

  init() {
    let userUrl1 = self.setUserUrlProperty.signal.skipNil()
    let userUrl3 = Signal.combineLatest(userUrl1, self.tappedRefleshButtonProperty.signal).map(first)

    let userUrl = Signal.merge(userUrl1, userUrl3)



    let user1 = userUrl.observe(on: QueueScheduler())
      .map {
        AppEnvironment.current.apiService.user(referredBy: $0).single()
      }
      .map {(result) -> User? in
        let r = result
        return r?.value
      }.skipNil().map { (u) -> User in

        /// This map contains side effect, need to refactor this code

        if let user = AppEnvironment.current.currentUser, user == u {
          AppEnvironment.updateCurrentUser(u)
        }
        return u
    }

    let user2 = self.setUserProperty.signal.skipNil()

    let user = Signal.merge(user1, user2)
    let userDisplay = Signal.combineLatest(user, self.viewDidLoadProperty.signal).map(first)

    self.user = userDisplay

    self.userAvatar = userDisplay.observeInBackground().map{ (u) -> UIImage? in
      let url = u.avatar.url
      guard let imgData = try? Data(contentsOf: url),
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
  public func set(user: User) {
    self.setUserProperty.value = user
  }

  fileprivate let setUserUrlProperty = MutableProperty<URL?>(nil)
  public func set(userUrl: URL) {
    self.setUserUrlProperty.value = userUrl
  }

  fileprivate let tappedEventProperty = MutableProperty<UserProfileEventTableViewCellConfig?>(nil)
  public func tappedEvent(eventConfig: UserProfileEventTableViewCellConfig) {
    self.tappedEventProperty.value = eventConfig
  }

  fileprivate let tappedRefleshButtonProperty = MutableProperty()
  public func tappedRefleshButton() {
    self.tappedRefleshButtonProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let viewWillAppearProperty = MutableProperty<Bool?>(nil)
  public func viewWillAppear(animated: Bool) {
    self.viewWillAppearProperty.value = animated
  }


  public let events: Signal<[UserProfileEventTableViewCellConfig], NoError>
  public let organizations: Signal<[UserProfileOrganizationTableViewCellConfig], NoError>
  public let user: Signal<User, NoError>
  public let userAvatar: Signal<UIImage, NoError>

  public var inputs: UserProfileViewModelInputs { return self }
  public var outputs: UserProfileViewModelOutputs { return self}
}

















