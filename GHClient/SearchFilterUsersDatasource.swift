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
    
    internal func load(userTypes:[UserType]) {
        let texts = userTypes.map{$0.rawValue}
        self.set(values: texts,
                 cellClass: RegularCollectionViewCell.self,
                 inSection: Section.userType.rawValue)
    }
    
    internal func load(searchFields: [UserInArgument]) {
        let texts = searchFields.map{$0.rawValue}
        self.set(values: texts,
                 cellClass: RegularCollectionViewCell.self,
                 inSection: Section.searchField.rawValue)
    }
    
    internal func setReposRange() {
        self.set(values: [(nil, nil)],
                 cellClass: NumberRangeCollectionViewCell.self,
                 inSection: Section.reposCount.rawValue)
    }
    
    internal func load(cities: [String]) {
        self.set(values: cities,
                 cellClass: RegularCollectionViewCell.self,
                 inSection: Section.cities.rawValue)
    }
    
    internal func load(languages: [LanguageArgument]) {
        self.set(values: languages.map{$0.rawValue},
                 cellClass: RegularCollectionViewCell.self,
                 inSection: Section.language.rawValue)
    }
    
    internal func setCreatedDateRange() {
        self.set(values: [(nil, nil)],
                 cellClass: DateRangeCollectionViewCell.self,
                 inSection: Section.createdDate.rawValue)
    }
    
    internal func setFollowersRange() {
        self.set(values: [(nil, nil)],
                 cellClass: NumberRangeCollectionViewCell.self,
                 inSection: Section.followersCount.rawValue)
    }
    
    override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as RegularCollectionViewCell, item as String):
            cell.configureWith(value: item)
        case let (cell as NumberRangeCollectionViewCell, item as NumberRange):
            cell.configureWith(value: item)
        case let (cell as DateRangeCollectionViewCell, item as DateRange):
            cell.configureWith(value: item)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
}

























