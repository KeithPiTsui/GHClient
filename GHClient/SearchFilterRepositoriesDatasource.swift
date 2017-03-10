//
//  SearchFilterRepositoriesDatasource.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class SearchFilterRepositoriesDatasource: ValueCellDataSource {
    
    internal func load(filterOptions: RepositorySearchQualifierOptions) {
        
    }
    
}

extension SearchFilterRepositoriesDatasource {
    internal func indexPaths(for qualifiers: [RepositoriesQualifier]) -> [IndexPath] {
        
        
        return []
    }
}

extension SearchFilterRepositoriesDatasource {
    internal func userQualifiers(with indexPaths: [IndexPath]) -> [RepositoriesQualifier] {
        var returnedUserQualifiers: [RepositoriesQualifier] = []
        
        return returnedUserQualifiers
    }
}
