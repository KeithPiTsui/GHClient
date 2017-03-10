//
//  SearchFilterRepositoriesDatasource.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal struct RepositorySearchQualifierOptions {
    internal let searchIn: [RepositoriesInArgument]
    internal let size: ComparativeArgument<UInt>
    internal let forks: ComparativeArgument<UInt>
    internal let fork: [RepositoriesForkArgument]
    internal let created: ComparativeArgument<Date>
    internal let pushed: ComparativeArgument<Date>
    internal let user: String
    internal let language: [LanguageArgument]
    internal let star: ComparativeArgument<UInt>
}


internal final class SearchFilterRepositoriesDatasource: ValueCellDataSource, FilterDataSource {
    fileprivate enum Section: Int {
        case Field
        case Size
        case Forks
        case Forked
        case CreatedDate
        case PushedDate
        case UserName
        case Languages
        case Stars

        internal var name: String {return String(describing: self)}
    }
    
    internal func load(filterOptions: RepositorySearchQualifierOptions) {
        self.load(searchFields: filterOptions.searchIn)
        self.set(size: filterOptions.size)
        self.set(forks: filterOptions.forks)
        self.load(forked: filterOptions.fork)
        self.set(createdDateRange: filterOptions.created)
        self.set(pushedDateRange: filterOptions.pushed)
        self.set(user: filterOptions.user)
        self.load(languages: filterOptions.language)
        self.set(stars: filterOptions.star)
    }
    
    internal var rangeSections: [Int] {
        return [Section.Size.rawValue,
                Section.Forks.rawValue,
                Section.CreatedDate.rawValue,
                Section.PushedDate.rawValue,
                Section.Stars.rawValue]
    }
    
    internal var multiChoiceSection: [Int] {
        return [Section.Field.rawValue,
                Section.Languages.rawValue]
    }
    
    internal var singleChoiceSection: [Int] {
        return [Section.Forked.rawValue]
    }
    
    
    
    internal func load(searchFields: [RepositoriesInArgument]) {
        self.set(values: searchFields,
                 cellClass: RegularCollectionViewCell.self,
                 inSection: Section.Field.rawValue)
    }
    
    internal func set(size: ComparativeArgument<UInt>) {
        self.set(values: [size],
                 cellClass: NumberRangeCollectionViewCell.self,
                 inSection: Section.Size.rawValue)
    }
    
    internal func set(forks: ComparativeArgument<UInt>) {
        self.set(values: [forks],
                 cellClass: NumberRangeCollectionViewCell.self,
                 inSection: Section.Forks.rawValue)
    }
    
    internal func load(forked: [RepositoriesForkArgument]) {
        self.set(values: forked,
                 cellClass: RegularCollectionViewCell.self,
                 inSection: Section.Forked.rawValue)
    }
    
    internal func set(user: String) {
        self.set(values: [user],
                 cellClass: RegularTextFieldCollectionViewCell.self,
                 inSection: Section.UserName.rawValue)
    }
    
    internal func load(languages: [LanguageArgument]) {
        self.set(values: languages,
                 cellClass: RegularCollectionViewCell.self,
                 inSection: Section.Languages.rawValue)
    }
    
    internal func set(createdDateRange: ComparativeArgument<Date>) {
        self.set(values: [createdDateRange],
                 cellClass: DateRangeCollectionViewCell.self,
                 inSection: Section.CreatedDate.rawValue)
    }
    
    internal func set(pushedDateRange: ComparativeArgument<Date>) {
        self.set(values: [pushedDateRange],
                 cellClass: DateRangeCollectionViewCell.self,
                 inSection: Section.PushedDate.rawValue)
    }
    
    internal func set(stars: ComparativeArgument<UInt>) {
        self.set(values: [stars],
                 cellClass: NumberRangeCollectionViewCell.self,
                 inSection: Section.Stars.rawValue)
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
    
    internal func collectionView(_ collectionView: UICollectionView,
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

extension SearchFilterRepositoriesDatasource {
    internal func qualifiers(with indexPaths: [IndexPath]) -> [SearchQualifier] {
        let returnedUserQualifiers: [RepositoriesQualifier] = []
        
        return returnedUserQualifiers
    }
}
