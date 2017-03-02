//
//  AppDelegateViewModel.swift
//  GHClient
//
//  Created by Pi on 02/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result


public protocol AppDelegateViewModelInputs {
    
}

public protocol AppDelegateViewModelOutputs {
    
}

public protocol AppDelegateViewModelType {
    var inputs: AppDelegateViewModelInputs {get}
    var outputs: AppDelegateViewModelOutputs {get}
}

public final class AppDelegateViewModel: AppDelegateViewModelType, AppDelegateViewModelInputs, AppDelegateViewModelOutputs {
    
    
    public var inputs: AppDelegateViewModelInputs { return self }
    public var outputs: AppDelegateViewModelOutputs { return self }
}
