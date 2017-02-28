//
//  LoginViewModel.swift
//  GHClient
//
//  Created by Pi on 28/02/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import Foundation
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result
import GHAPI

public protocol LoginViewModelInputs {
    
    /// Call when username text field was edit
    func usernameEdit(_ newName: String)
    
    /// Call when password text field was edit
    func passwordEdit(_ newPassword: String)
    
    /// Call when authToken text field was edit
    func authTokenEdit(_ newToken: String)
    
    /// Call when pushToken text field was edit
    func pushTokenEdit(_ newToken: String)
    
    /// Call when save account button was tapped
    func tappedSaveAccount(_ account: Account)
    
    /// Call when remove account button was tapped
    func tappedRemoveAccount()
    
    /// Call when a user session ends.
    func userSessionEnded()
    
    /// Call when a user session has started.
    func userSessionStarted()
    
    /// Call when the view did load.
    func viewDidLoad()
    
    /// Call when the view will appear with animated property.
    func viewWillAppear(animated: Bool)
}

public protocol LoginViewModelOutputs {
    var account: Signal<Account?, NoError> {get}
    var saveAccountButtonEnable: Signal<Bool, NoError> {get}
    var removeAccountButtonEnable: Signal<Bool, NoError> {get}
//    var accountSaving: Signal<(),NoError> {get}
//    var accountSaved: Signal<(), NoError> {get}
//    var accountDeleting: Signal<(), NoError> {get}
//    var accountDeleted: Signal<(), NoError> {get}
}

public protocol LoginViewModelType {
    var inputs: LoginViewModelInputs {get}
    var outputs: LoginViewModelOutputs {get}
}


public final class LoginViewModel: LoginViewModelType, LoginViewModelInputs, LoginViewModelOutputs {
    
    public init() {
        
        self.account = self.accountProperty.signal
        
        let combinedEditSignal = Signal.combineLatest(self.usernameProperty.signal,
                                                      self.passwordProperty.signal,
                                                      self.authTokenProperty.signal,
                                                      self.pushTokenProperty.signal)
        
        
        
        self.saveAccountButtonEnable = combinedEditSignal.map{ (username, password, authToken, pushToken) -> Bool in
            if username == nil { return false }
            if password == nil && authToken == nil { return false }
            return true
        }

        
        self.removeAccountButtonEnable = self.account.map{$0 != nil}
        
        self.account.observeValues{ [weak self] in
            self?.usernameProperty.value = $0?.username
            self?.passwordProperty.value = $0?.password
            self?.authTokenProperty.value = $0?.accessToken
            self?.pushTokenProperty.value = $0?.pushToken
        }
        
        self.viewDidLoadProperty.signal.observeValues { [weak self] in
            self?.accountProperty.value = Account.saved()
        }
        
        self.tappedSaveAccountProperty.signal.skipNil().observeValues { [weak self] in
            self?.accountProperty.value = $0
            _ = Account.save(account: $0)
        }
        
    }
    
    fileprivate let usernameProperty = MutableProperty<String?>(nil)
    public func usernameEdit(_ newName: String) {
        self.usernameProperty.value = newName
    }
    
    fileprivate let passwordProperty = MutableProperty<String?>(nil)
    public func passwordEdit(_ newPassword: String) {
        self.passwordProperty.value = newPassword
    }
    
    fileprivate let authTokenProperty = MutableProperty<String?>(nil)
    public func authTokenEdit(_ newToken: String) {
        self.authTokenProperty.value = newToken
    }
    
    fileprivate let pushTokenProperty = MutableProperty<String?>(nil)
    public func pushTokenEdit(_ newToken: String) {
        self.pushTokenProperty.value = newToken
    }
    
    
    fileprivate let tappedSaveAccountProperty = MutableProperty<Account?>(nil)
    public func tappedSaveAccount(_ account: Account) {
        self.tappedSaveAccountProperty.value = account
    }
    
    fileprivate let tappedRemoveAccountProperty = MutableProperty()
    public func tappedRemoveAccount() {
        self.tappedRemoveAccountProperty.value = ()
    }
    
    fileprivate let userSessionStartedProperty = MutableProperty(())
    public func userSessionStarted() {
        self.userSessionStartedProperty.value = ()
    }
    fileprivate let userSessionEndedProperty = MutableProperty(())
    public func userSessionEnded() {
        self.userSessionEndedProperty.value = ()
    }
    
    fileprivate let viewDidLoadProperty = MutableProperty()
    public func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    fileprivate let viewWillAppearProperty = MutableProperty<Bool?>(nil)
    public func viewWillAppear(animated: Bool) {
        self.viewWillAppearProperty.value = animated
    }
    
    fileprivate let accountProperty = MutableProperty<Account?>(nil)
    
    public let account: Signal<Account?, NoError>
    public let saveAccountButtonEnable: Signal<Bool, NoError>
    public let removeAccountButtonEnable: Signal<Bool, NoError>
    
    public var inputs: LoginViewModelInputs {return self}
    public var outputs: LoginViewModelOutputs { return self}
}
