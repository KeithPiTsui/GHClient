//
//  SearchFilterUsersDatasource.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class SearchFilterUsersDatasource: ValueCellDataSource {
    internal enum Section: Int {
        case userType
        case searchField
        case reposCount
        case cities
        case language
        case createdDate
        case followersCount
    }
}


//case type(UserType)
//case `in`([UserInArgument])
//case repos(ComparativeArgument<UInt>)
//case location(String)
//case language([LanguageArgument])
//case created(ComparativeArgument<Date>)
//case followers(ComparativeArgument<UInt>)

