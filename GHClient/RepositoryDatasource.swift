//
//  RepositoryDatasource.swift
//  GHClient
//
//  Created by Pi on 11/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

fileprivate enum Section: Int {
    case userType
    case searchField
    case reposCount
    case cities
    case language
    case createdDate
    case followersCount
    
    internal var name: String {
        return String(describing: self)
    }
}
extension Section: HashableEnumCaseIterating {}

internal final class RepositoryDatasource: ValueCellDataSource {

}
