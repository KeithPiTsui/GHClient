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
        
        internal var name: String {
            switch self {
            case .userType:
                return "User Type"
            case .searchField:
                return "Search Field"
            case .reposCount:
                return "Repos Range"
            case .cities:
                return "Located Cities"
            case .language:
                return "Languages"
            case .createdDate:
                return "Created Date Range"
            case .followersCount:
                return "Followers Range"
            }
        }
    }
    
    internal var rangeSections: [Int] {
        return [Section.reposCount.rawValue, Section.createdDate.rawValue, Section.followersCount.rawValue]
    }
    
    internal var multiChoiceSection: [Int] {
        return [Section.searchField.rawValue, Section.cities.rawValue, Section.language.rawValue]
    }
    
    internal var singleChoiceSection: [Int] {
        return [Section.userType.rawValue]
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
    
    override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any, for indexPath: IndexPath) {
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

extension SearchFilterUsersDatasource {
    internal func userQualifiers(with indexPaths: [IndexPath]) -> [UserQualifier] {
        var returnedUserQualifiers: [UserQualifier] = []
        
        // user type
        let userTypeIndice = indexPaths.filter{$0.section == Section.userType.rawValue}
        var userTypeQualifiers: [UserQualifier] = []
        userTypeIndice.forEach {
            guard let s = self[$0] as? String else { return }
            guard let x = UserType.init(rawValue: s) else { return }
            userTypeQualifiers.append(UserQualifier.type(x))
        }
        if userTypeQualifiers.isEmpty == false {
            returnedUserQualifiers.append(contentsOf: userTypeQualifiers)
        }
        
        // search field
        let searchFieldIndice = indexPaths.filter{$0.section == Section.searchField.rawValue}
        var userInArguments: [UserInArgument] = []
        searchFieldIndice.forEach {
            guard let s = self[$0] as? String else { return }
            guard let x = UserInArgument.init(rawValue: s) else { return }
            userInArguments.append(x)
        }
        
        if userInArguments.isEmpty == false {
            returnedUserQualifiers.append(UserQualifier.in(userInArguments))
        }
        
        // reposCount
        let ip = IndexPath(item: 0, section: Section.reposCount.rawValue)
        var reposCountQualifiers = [UserQualifier]()
        if let s = self[ip] as? NumberRange {
            switch (s.0, s.1) {
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
        
        // language
        let languageIndice = indexPaths.filter{$0.section == Section.language.rawValue}
        var languageArguments: [LanguageArgument] = []
        languageIndice.forEach {
            guard let s = self[$0] as? String else { return }
            guard let x = LanguageArgument.init(rawValue: s) else { return }
            languageArguments.append(x)
        }
        
        if userInArguments.isEmpty == false {
            returnedUserQualifiers.append(UserQualifier.language(languageArguments))
        }
        
        
        // CreatedDate
        let cip = IndexPath(item: 0, section: Section.createdDate.rawValue)
        var createdDateQualifiers = [UserQualifier]()
        if let s = self[cip] as? DateRange {
            switch (s.0, s.1) {
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
        if let s = self[fip] as? NumberRange {
            switch (s.0, s.1) {
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

//public final subscript(indexPath: IndexPath) -> Any {
//    return self.values[indexPath.section][indexPath.item].value
//}


















