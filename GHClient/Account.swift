//
//  Account.swift
//  GHClient
//
//  Created by Pi on 28/02/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import Foundation


public struct Account {
    let username: String
    let password: String?
    let accessToken: String?
    let pushToken: String?
    
    public static func saved() -> Account? {
        guard let username = UserDefaults.standard.value(forKey: "username") as? String else { return nil }
        let password = UserDefaults.standard.value(forKey: "password") as? String
        let accessToken = UserDefaults.standard.value(forKey: "accessToken") as? String
        let pushToken = UserDefaults.standard.value(forKey: "pushToken") as? String
        return Account(username: username, password: password, accessToken: accessToken, pushToken: pushToken)
    }
    
    public static func save(account: Account) -> Bool {
        UserDefaults.standard.set(account.username, forKey: "username")
        UserDefaults.standard.set(account.password, forKey: "password")
        UserDefaults.standard.set(account.accessToken, forKey: "accessToken")
        UserDefaults.standard.set(account.pushToken, forKey: "pushToken")
        return UserDefaults.standard.synchronize()
    }
}
