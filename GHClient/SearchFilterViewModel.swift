//
//  SearchFilterViewModel.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import Foundation

internal protocol SearchFilterViewModelInputs {
    
}

internal protocol SearchFilterViewModelOutputs{
    
}

internal protocol SearchFilterViewModelType{
    var inputs: SearchFilterViewModelInputs {get}
    var outputs: SearchFilterViewModelOutputs {get}
}

internal final class SearchFilterViewModel: SearchFilterViewModelType, SearchFilterViewModelInputs, SearchFilterViewModelOutputs {
    
    
    
    internal var inputs: SearchFilterViewModelInputs { return self }
    internal var outputs: SearchFilterViewModelOutputs { return self }
}
