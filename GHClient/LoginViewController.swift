//
//  LoginViewController.swift
//  GHClient
//
//  Created by Pi on 28/02/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    fileprivate let viewModel: LoginViewModelType = LoginViewModel()
    
    
    @IBOutlet weak var NotificationPushSwitch: UISwitch!
    @IBOutlet weak var pushTokenTF: UITextField!
    @IBOutlet weak var authTokenTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var saveAccountBtn: UIButton!
    @IBOutlet weak var removeAccountBtn: UIButton!
    
    internal static func instantiate() -> LoginViewController {
        return Storyboard.Login.instantiate(LoginViewController.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    internal override func bindStyles() {
        super.bindStyles()
    }
    
    internal override func bindViewModel() {
        super.bindViewModel()
    }
    
    
}
