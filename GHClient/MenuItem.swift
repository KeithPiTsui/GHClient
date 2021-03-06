//
//  MenuItem.swift
//  GHClient
//
//  Created by Pi on 03/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

fileprivate let itemIconNames: [String: String] =
  ["Personal.UserProfile": "tabbar-icon-profile-logged-out",
   "Personal.PersonalRepos": "tabbar-icon-profile-logged-out",
   "Personal.WathcedRepos": "tabbar-icon-profile-logged-out",
   "Personal.StarredRepos": "tabbar-icon-profile-logged-out",
   "Personal.IssuesRequests": "tabbar-icon-profile-logged-out",
   "Personal.PersonalGists": "tabbar-icon-profile-logged-out",
   "Personal.StarredGists": "tabbar-icon-profile-logged-out",
   "Personal.Feeds": "tabbar-icon-profile-logged-out",
   "Discovery.Searching": "tabbar-icon-search",
   "Discovery.Trending": "tabbar-icon-search",
   "App.Settings": "phone-icon",
   "App.Feedback": "phone-icon"]

internal enum MenuItem {
  internal enum PersonalItem: String {
    case UserProfile
    case PersonalRepos
    case WathcedRepos
    case StarredRepos
    case IssuesRequests
    case PersonalGists
    case StarredGists
    case Feeds
  }

  internal enum DiscoveryItem: String {
    case Searching
    case Trending
  }

  internal enum AppItem: String {
    case Settings
    case Feedback
  }

  case Personal(PersonalItem)
  case Discovery(DiscoveryItem)
  case App(AppItem)

  internal var itemCategoryName: String {
    switch self {
    case .Personal(_):
      return "Personal"
    case .Discovery(_):
      return "Discovery"
    case .App(_):
      return "App"
    }
  }

  internal var itemName: String {
    switch self {
    case .Personal(let item):
      return item.rawValue
    case .Discovery(let item):
      return item.rawValue
    case .App(let item):
      return item.rawValue
    }
  }

  internal var itemFullName: String {
    return self.itemCategoryName + "." + self.itemName
  }

  internal var itemIcon: UIImage {
    guard let itemIconName = itemIconNames[self.itemFullName] else {
      fatalError("No corresponding Icon Name for item \(self.itemFullName)")
    }
    guard let img = UIImage(named: itemIconName) else {
      fatalError("No corresponding Icon for name \(itemIconName)")
    }
    return img
  }
}























