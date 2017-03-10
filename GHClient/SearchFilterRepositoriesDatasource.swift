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
        var rqs: [RepositoriesQualifier] = []
        
        // Forks
        let forkedIndice = indexPaths.filter{$0.section == Section.Forked.rawValue}
        var forkedQualifiers: [RepositoriesQualifier] = []
        forkedIndice.forEach {
            guard let s = self[$0] as? RepositoriesForkArgument else { return }
            forkedQualifiers.append(RepositoriesQualifier.fork(s))
        }
        if forkedQualifiers.isEmpty == false {
            rqs.append(contentsOf: forkedQualifiers)
        }
        
        
        // search field
        let searchFieldIndice = indexPaths.filter{$0.section == Section.Field.rawValue}
        var inArguments: [RepositoriesInArgument] = []
        searchFieldIndice.forEach {
            guard let s = self[$0] as? RepositoriesInArgument else { return }
            inArguments.append(s)
        }
        
        if inArguments.isEmpty == false {
            rqs.append(RepositoriesQualifier.in(inArguments))
        }
        
        // Size
        let ip = IndexPath(item: 0, section: Section.Size.rawValue)
        var sizeQualifiers = [RepositoriesQualifier]()
        if let s = self[ip] as? ComparativeArgument<UInt> {
            switch (s.lower, s.upper) {
            case (nil, nil):
                break
            case let (left?, right?):
                let maxN = UInt(max(left, right))
                let minN = UInt(min(left, right))
                sizeQualifiers.append(.size(.between(minN, maxN)))
            case let (nil, right?):
                let minN = UInt(right)
                sizeQualifiers.append(.size(.lessAndEqualThan(minN)))
            case let (left?, nil):
                let maxN = UInt(left)
                sizeQualifiers.append(.size(.biggerAndEqualThan(maxN)))
            }
        }
        if sizeQualifiers.isEmpty == false {
            rqs.append(contentsOf: sizeQualifiers)
        }
        
        // UserName
        let unip = IndexPath(item: 0, section: Section.UserName.rawValue)
        var unQualifiers = [RepositoriesQualifier]()
        if let s = self[unip] as? String {
            unQualifiers.append(RepositoriesQualifier.user([s]))
        }
        if unQualifiers.isEmpty == false {
            rqs.append(contentsOf: unQualifiers)
        }
        
        // language
        let languageIndice = indexPaths.filter{$0.section == Section.Languages.rawValue}
        var languageArguments: [LanguageArgument] = []
        languageIndice.forEach {
            guard let s = self[$0] as? LanguageArgument else { return }
            languageArguments.append(s)
        }
        
        if languageArguments.isEmpty == false {
            rqs.append(RepositoriesQualifier.language(languageArguments))
        }
        
        
        // CreatedDate
        let cip = IndexPath(item: 0, section: Section.CreatedDate.rawValue)
        var createdDateQualifiers = [RepositoriesQualifier]()
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
            rqs.append(contentsOf: createdDateQualifiers)
        }
        
        // pushedDate
        let pip = IndexPath(item: 0, section: Section.PushedDate.rawValue)
        var pushedDateQualifiers = [RepositoriesQualifier]()
        if let s = self[pip] as? ComparativeArgument<Date> {
            switch (s.lower, s.upper) {
            case (nil, nil):
                break
            case let (left?, right?):
                let maxN = max(left, right)
                let minN = min(left, right)
                pushedDateQualifiers.append(.pushed(.between(minN, maxN)))
            case let (nil, right?):
                pushedDateQualifiers.append(.pushed(.lessAndEqualThan(right)))
            case let (left?, nil):
                pushedDateQualifiers.append(.pushed(.biggerAndEqualThan(left)))
            }
        }
        if pushedDateQualifiers.isEmpty == false {
            rqs.append(contentsOf: pushedDateQualifiers)
        }
        
        // stars
        let fip = IndexPath(item: 0, section: Section.Stars.rawValue)
        var followersCountQualifiers = [RepositoriesQualifier]()
        if let s = self[fip] as? ComparativeArgument<UInt> {
            switch (s.lower, s.upper) {
            case (nil, nil):
                break
            case let (left?, right?):
                let maxN = UInt(max(left, right))
                let minN = UInt(min(left, right))
                followersCountQualifiers.append(.stars(.between(minN, maxN)))
            case let (nil, right?):
                let minN = UInt(right)
                followersCountQualifiers.append(.stars(.lessAndEqualThan(minN)))
            case let (left?, nil):
                let maxN = UInt(left)
                followersCountQualifiers.append(.stars(.biggerAndEqualThan(maxN)))
            }
        }
        if followersCountQualifiers.isEmpty == false {
            rqs.append(contentsOf: followersCountQualifiers)
        }
        
        // forks
        let forksIp = IndexPath(item: 0, section: Section.Forks.rawValue)
        var forksQualifiers = [RepositoriesQualifier]()
        if let s = self[forksIp] as? ComparativeArgument<UInt> {
            switch (s.lower, s.upper) {
            case (nil, nil):
                break
            case let (left?, right?):
                let maxN = UInt(max(left, right))
                let minN = UInt(min(left, right))
                forksQualifiers.append(.forks(.between(minN, maxN)))
            case let (nil, right?):
                let minN = UInt(right)
                forksQualifiers.append(.forks(.lessAndEqualThan(minN)))
            case let (left?, nil):
                let maxN = UInt(left)
                forksQualifiers.append(.forks(.biggerAndEqualThan(maxN)))
            }
        }
        if forksQualifiers.isEmpty == false {
            rqs.append(contentsOf: forksQualifiers)
        }
        
        return rqs
    }
}
