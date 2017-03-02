//
//  UserProfileViewController.swift
//  GHClient
//
//  Created by Pi on 02/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

final class UserProfileViewController: UITableViewController {

    @IBAction func openMenu(_ sender: UIBarButtonItem) {
        guard let menu = self.slideMenuController() else { return }
        menu.openLeft()
    }
    internal static func instantiate() -> UserProfileViewController {
        return Storyboard.UserProfile.instantiate(UserProfileViewController.self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
