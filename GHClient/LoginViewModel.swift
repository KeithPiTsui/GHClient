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
    
}

public protocol LoginViewModelOutputs {
    
}

public protocol LoginViewModelType {
    var inputs: LoginViewModelInputs {get}
    var outputs: LoginViewModelOutputs {get}
}


public final class LoginViewModel: LoginViewModelType, LoginViewModelInputs, LoginViewModelOutputs {
    
    public var inputs: LoginViewModelInputs {return self}
    public var outputs: LoginViewModelOutputs { return self}
}
