//
//  UserProfileViewController.swift
//  GHClient
//
//  Created by Pi on 02/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

final class UserProfileViewController: UITableViewController {

    internal static func instantiate() -> UserProfileViewController {
        return Storyboard.UserProfile.instantiate(UserProfileViewController.self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
