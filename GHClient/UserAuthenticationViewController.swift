//
//  UserAuthenticationViewController.swift
//  GHClient
//
//  Created by Pi on 11/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveExtensions
import ReactiveSwift
import ReactiveCocoa
import Result

internal final class UserAuthenticationViewController: UIViewController {

  internal static func instantiate() -> UserAuthenticationViewController {
    return Storyboard.UserAuthentication.instantiate(UserAuthenticationViewController.self)
  }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
