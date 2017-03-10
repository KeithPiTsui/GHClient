//
//  SearchFilterUsersDatasource.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal struct UserSearchQualifierOptions {
    internal let userTypes: [UserType]
    internal let userInArguments: [UserInArgument]
    internal let reposRange: ComparativeArgument<UInt>
    internal let city: String
    internal let programmingLanguages: [LanguageArgument]
    internal let createdDateRange: ComparativeArgument<Date>
    internal let followersRange: ComparativeArgument<UInt>
}

internal protocol FilterDataSource {
    var rangeSections: [Int] {get}
    var multiChoiceSection: [Int] {get}
    var singleChoiceSection: [Int] {get}
    func qualifiers(with indexPaths: [IndexPath]) -> [SearchQualifier]
}

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

internal final class SearchFilterUsersDatasource: ValueCellDataSource, FilterDataSource {
    
    
    internal var rangeSections: [Int] {
        return [Section.reposCount.rawValue,
                Section.createdDate.rawValue,
                Section.followersCount.rawValue,
                Section.cities.rawValue]
    }
    
    internal var multiChoiceSection: [Int] {
        return [Section.searchField.rawValue,
                Section.cities.rawValue,
                Section.language.rawValue]
    }
    
    internal var singleChoiceSection: [Int] {
        return [Section.userType.rawValue]
    }
    
    internal func load(filterOptions: UserSearchQualifierOptions) {
        self.load(userTypes: filterOptions.userTypes)
        self.load(searchFields: filterOptions.userInArguments)
        self.set(reposRange: filterOptions.reposRange)
        self.set(city: filterOptions.city)
        self.load(languages: filterOptions.programmingLanguages)
        self.set(createdDateRange: filterOptions.createdDateRange)
        self.set(followersRange: filterOptions.followersRange)
    }
    
    internal func load(userTypes:[UserType]) {
        self.set(values: userTypes,
                 cellClass: RegularCollectionViewCell.self,
                 inSection: Section.userType.rawValue)
    }
    
    internal func load(searchFields: [UserInArgument]) {
        self.set(values: searchFields,
                 cellClass: RegularCollectionViewCell.self,
                 inSection: Section.searchField.rawValue)
    }
    
    internal func set(reposRange: ComparativeArgument<UInt>) {
        self.set(values: [reposRange],
                 cellClass: NumberRangeCollectionViewCell.self,
                 inSection: Section.reposCount.rawValue)
    }
    
    internal func set(city: String) {
        self.set(values: [city],
                 cellClass: RegularTextFieldCollectionViewCell.self,
                 inSection: Section.cities.rawValue)
    }
    
    internal func load(languages: [LanguageArgument]) {
        self.set(values: languages,
                 cellClass: RegularCollectionViewCell.self,
                 inSection: Section.language.rawValue)
    }
    
    internal func set(createdDateRange: ComparativeArgument<Date>) {
        self.set(values: [createdDateRange],
                 cellClass: DateRangeCollectionViewCell.self,
                 inSection: Section.createdDate.rawValue)
    }
    
    internal func set(followersRange: ComparativeArgument<UInt>) {
        self.set(values: [followersRange],
                 cellClass: NumberRangeCollectionViewCell.self,
                 inSection: Section.followersCount.rawValue)
    }
    
    override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any, for indexPath: IndexPath) {
        switch (cell, value) {
        case let (cell as RegularCollectionViewCell, item as CustomStringConvertible):
            cell.configureWith(value: item)
        case let (cell as NumberRangeCollectionViewCell, item as ComparativeArgument<UInt>):
            cell.configureWith(value: item)
        case let (cell as DateRangeCollectionViewCell, item as ComparativeArgument<Date>):
            cell.configureWith(value: item)
        case let (cell as RegularTextFieldCollectionViewCell, item as String):
            cell.configureWith(value: item)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        let v = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                withReuseIdentifier: "UICollectionElementKindSectionHeader",
                                                                for: indexPath)
        guard let lab = v.viewWithTag(1) as? UILabel
            else {
                fatalError("Cannot reach section header label")
            }
        lab.text = Section.init(rawValue: indexPath.section)?.name
        return v
    }
}

extension ValueCellDataSource {
    internal func indexPath<ItemType: Equatable>(for item: ItemType) -> IndexPath? {
        let values = self.valueSnapshot
        for (sec, uqs)  in values.enumerated() {
            guard let userTypes = uqs as? [ItemType] else { continue }
            guard let idx = userTypes.index(of: item) else { continue }
            return IndexPath(item: idx, section: sec)
        }
        return nil
    }
}

extension SearchFilterUsersDatasource {
    internal func qualifiers(with indexPaths: [IndexPath]) -> [SearchQualifier] {
        var returnedUserQualifiers: [UserQualifier] = []
    
        
        // user type
        let userTypeIndice = indexPaths.filter{$0.section == Section.userType.rawValue}
        var userTypeQualifiers: [UserQualifier] = []
        userTypeIndice.forEach {
            guard let s = self[$0] as? UserType else { return }
            userTypeQualifiers.append(UserQualifier.type(s))
        }
        if userTypeQualifiers.isEmpty == false {
            returnedUserQualifiers.append(contentsOf: userTypeQualifiers)
        }
        
        // search field
        let searchFieldIndice = indexPaths.filter{$0.section == Section.searchField.rawValue}
        var userInArguments: [UserInArgument] = []
        searchFieldIndice.forEach {
            guard let s = self[$0] as? UserInArgument else { return }
            userInArguments.append(s)
        }
        
        if userInArguments.isEmpty == false {
            returnedUserQualifiers.append(UserQualifier.in(userInArguments))
        }
        
        // reposCount
        let ip = IndexPath(item: 0, section: Section.reposCount.rawValue)
        var reposCountQualifiers = [UserQualifier]()
        if let s = self[ip] as? ComparativeArgument<UInt> {
            switch (s.lower, s.upper) {
            case (nil, nil):
                break
            case let (left?, right?):
                let maxN = UInt(max(left, right))
                let minN = UInt(min(left, right))
                reposCountQualifiers.append(.repos(.between(minN, maxN)))
            case let (nil, right?):
                let minN = UInt(right)
                reposCountQualifiers.append(.repos(.lessAndEqualThan(minN)))
            case let (left?, nil):
                let maxN = UInt(left)
                reposCountQualifiers.append(.repos(.biggerAndEqualThan(maxN)))
            }
        }
        if reposCountQualifiers.isEmpty == false {
            returnedUserQualifiers.append(contentsOf: reposCountQualifiers)
        }
        
        // cities
        let cityip = IndexPath(item: 0, section: Section.cities.rawValue)
        var CityQualifiers = [UserQualifier]()
        if let s = self[cityip] as? String, s.isEmpty == false {
            CityQualifiers.append(UserQualifier.location(s))
        }
        if CityQualifiers.isEmpty == false {
            returnedUserQualifiers.append(contentsOf: CityQualifiers)
        }
        
        // language
        let languageIndice = indexPaths.filter{$0.section == Section.language.rawValue}
        var languageArguments: [LanguageArgument] = []
        languageIndice.forEach {
            guard let s = self[$0] as? LanguageArgument else { return }
            languageArguments.append(s)
        }
        
        if languageArguments.isEmpty == false {
            returnedUserQualifiers.append(UserQualifier.language(languageArguments))
        }
        
        
        // CreatedDate
        let cip = IndexPath(item: 0, section: Section.createdDate.rawValue)
        var createdDateQualifiers = [UserQualifier]()
        if let s = self[cip] as? ComparativeArgument<Date> {
            switch (s.lower, s.upper) {
            case (nil, nil):
                break
            case let (left?, right?):
                let maxN = max(left, right)
                let minN = min(left, right)
                createdDateQualifiers.append(.created(.between(minN, maxN)))
            case let (nil, right?):
                createdDateQualifiers.append(.created(.lessAndEqualThan(right)))
            case let (left?, nil):
                createdDateQualifiers.append(.created(.biggerAndEqualThan(left)))
            }
        }
        if createdDateQualifiers.isEmpty == false {
            returnedUserQualifiers.append(contentsOf: createdDateQualifiers)
        }
        
        // followersCount
        let fip = IndexPath(item: 0, section: Section.followersCount.rawValue)
        var followersCountQualifiers = [UserQualifier]()
        if let s = self[fip] as? ComparativeArgument<UInt> {
            switch (s.lower, s.upper) {
            case (nil, nil):
                break
            case let (left?, right?):
                let maxN = UInt(max(left, right))
                let minN = UInt(min(left, right))
                followersCountQualifiers.append(.followers(.between(minN, maxN)))
            case let (nil, right?):
                let minN = UInt(right)
                followersCountQualifiers.append(.followers(.lessAndEqualThan(minN)))
            case let (left?, nil):
                let maxN = UInt(left)
                followersCountQualifiers.append(.followers(.biggerAndEqualThan(maxN)))
            }
        }
        if followersCountQualifiers.isEmpty == false {
            returnedUserQualifiers.append(contentsOf: followersCountQualifiers)
        }
        
        
        return returnedUserQualifiers
    }
}

















