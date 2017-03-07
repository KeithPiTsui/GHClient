//
//  Storyboard.swift
//  CryptoKeyboard
//
//  Created by Pi on 16/02/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

extension Bundle {
    /// Returns an NSBundle pinned to the framework target. We could choose anything for the `forClass`
    /// parameter as long as it is in the framework target.
    internal static var framework: Bundle { return Bundle(for: AppDelegate.self)}
}

public enum Storyboard: String {
    case Feedback
    case Feeds
    case IssuePullRequests
    case Login
    case Menu
    case PersonalGists
    case PersonalRepositories
    case RepositoryDetail
    case Search
    case SearchFilter
    case Settings
    case StarredGists
    case StarredRepositories
    case Trending
    case UserProfile
    case WatchedRepositories
    
    public func instantiate<VC: UIViewController>(_ viewController: VC.Type, inBundle bundle: Bundle = .framework) -> VC {
        guard
            let vc = UIStoryboard(name: self.rawValue, bundle: Bundle(identifier: bundle.identifier))
                .instantiateViewController(withIdentifier: VC.storyboardIdentifier) as? VC
            else { fatalError("Couldn't instantiate \(VC.storyboardIdentifier) from \(self.rawValue)") }
        return vc
    }
}
