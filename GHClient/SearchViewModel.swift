//
//  SearchViewModel.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result
import GHAPI
import Prelude

internal protocol SearchViewModelInputs {
    /// Call when the view did load.
    func viewDidLoad()
    
    /// Call when the view will appear with animated property.
    func viewWillAppear(animated: Bool)
    
    /// Call when a user session ends.
    func userSessionEnded()
    
    /// Call when a user session has started.
    func userSessionStarted()
    
    /// Call when user tap scope segment to change scope
    func scopeSegmentChanged(index: Int)
    
    /// Call when user search
    func search(scope: SearchScope, keyword: String, qualifiers: [SearchQualifier])
    
    /// Call when user tapped on filter button
    func tappedFilterButton(within scope: SearchScope)
    
    /// Call when user tapped on dim view
    func tappedOnDimView()
    
    /// Call when vc want to veil filter
    func wannaVeilFilter()
    
    /// Call when vc show filter
    func filter(showed: Bool)
    
}

internal protocol SearchViewModelOutputs {
    
    /// Emit a signal to update user data source
    var users: Signal<[User], NoError> { get }
    
    /// Emit a signal to update repository data source
    var repositories: Signal<[Repository], NoError> {get}
    
    /// Emit a signal to specify search scopes, user and repository
    var searchScopes: Signal<[SearchScope], NoError> { get }
    
    /// Emit a signal to specify selected search scopes
    var selectedSearchScope: Signal<SearchScope, NoError> { get }
    
    /// Emit a signal to notify vc to present filter view controller
    var presentSearchFilterViewController: Signal<SearchFilterViewController, NoError> {get}
    
    /// Emit a signal to notify vc to remove filter view controller
    var removeFilter: Signal<SearchFilterViewController, NoError> {get}
    
}

internal protocol SearchViewModelType {
    var inputs: SearchViewModelInputs { get }
    var outputs: SearchViewModelOutputs { get }
}


internal final class SearchViewModel: SearchViewModelType, SearchViewModelInputs, SearchViewModelOutputs {

    init() {
        self.searchScopes = self.viewDidLoadProperty.signal.map {[.users([])]}
        
        let scopeSignal1 = self.viewDidLoadProperty.signal.map{SearchScope.users([])}
        let scopeSignal2 = Signal.combineLatest(self.searchScopes, self.scopeSegmentChangedProperty.signal.skipNil()).map{$0[$1]}
        self.selectedSearchScope = Signal.merge(scopeSignal1, scopeSignal2)
        
        let filterViewController = self.viewDidLoadProperty.signal.map{_ in SearchFilterViewController.instantiate()}
        let filterButtonTap = self.tappedFilterButtonProperty.signal.skipNil()
        let filterShow = Signal.combineLatest(filterViewController, filterButtonTap)
        self.presentSearchFilterViewController = filterShow.map(first)
        
        let dimView = self.tappedOnDimViewProperty.signal
        let filterRemove = Signal.combineLatest(filterViewController, dimView)
        self.removeFilter = filterRemove.map(first)
        

        let search = self.searchWithQualifiersProperty.signal.skipNil().observe(on: QueueScheduler())
                    .filter{$0.keyword.isEmpty == false}
        
        self.users = search
                    .filter{$0.scope == .users([]) && $0.qualifiers is [UserQualifier]}
                    .map { (scope, keyword, qualifiers) -> ((SearchScope, String, [UserQualifier])?) in
                        guard let qualifiers = qualifiers as? [UserQualifier] else { return nil }
                        return (scope, keyword, qualifiers)
                    }.skipNil()
                    .map{
                        AppEnvironment.current.apiService
                            .searchUser(qualifiers: $2, keyword: $1, sort: .stars, order: .desc)
                            .single()
                            .map{$0.value?.items ?? []}
                    }.skipNil()

        self.repositories = search
                            .filter{$0.scope == .repositories([]) && $0.qualifiers is [RepositoriesQualifier]}
                            .map { (scope, keyword, qualifiers) -> ((SearchScope, String, [RepositoriesQualifier])?) in
                                guard let qualifiers = qualifiers as? [RepositoriesQualifier] else { return nil }
                                return (scope, keyword, qualifiers)
                            }.skipNil()
                            .map{
                                AppEnvironment.current.apiService
                                    .searchRepository(qualifiers: $2, keyword: $1, sort: .stars, order: .desc)
                                    .single()
                                    .map{$0.value?.items ?? []}
                            }.skipNil()
    }
    

    internal func wannaVeilFilter() {
        self.tappedOnDimViewProperty.value = ()
    }
    
    
    fileprivate let filterShowedProperty = MutableProperty<Bool>(false)
    internal func filter(showed: Bool) {
        self.filterShowedProperty.value = showed
    }
    
    /// Call when user search
    fileprivate let tappedOnDimViewProperty = MutableProperty()
    internal func tappedOnDimView() {
        self.tappedOnDimViewProperty.value = ()
    }
    
    fileprivate let searchWithQualifiersProperty = MutableProperty<(scope: SearchScope, keyword: String, qualifiers:[SearchQualifier])?>(nil)
    func search(scope: SearchScope, keyword: String, qualifiers: [SearchQualifier]){
        self.searchWithQualifiersProperty.value = (scope, keyword, qualifiers)
    }
    
    fileprivate let tappedFilterButtonProperty = MutableProperty<SearchScope?>(nil)
    internal func tappedFilterButton(within scope: SearchScope) {
        self.tappedFilterButtonProperty.value = scope
    }
    
    fileprivate let scopeSegmentChangedProperty = MutableProperty<Int?>(nil)
    internal func scopeSegmentChanged(index: Int) {
        self.scopeSegmentChangedProperty.value = index
    }
    
    fileprivate let userSessionStartedProperty = MutableProperty(())
    internal func userSessionStarted() {
        self.userSessionStartedProperty.value = ()
    }
    fileprivate let userSessionEndedProperty = MutableProperty(())
    internal func userSessionEnded() {
        self.userSessionEndedProperty.value = ()
    }
    
    fileprivate let viewDidLoadProperty = MutableProperty()
    internal func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    fileprivate let viewWillAppearProperty = MutableProperty<Bool?>(nil)
    internal func viewWillAppear(animated: Bool) {
        self.viewWillAppearProperty.value = animated
    }
    
    internal let users: Signal<[User], NoError>
    internal let repositories: Signal<[Repository], NoError>
    internal let searchScopes: Signal<[SearchScope], NoError>
    internal let selectedSearchScope: Signal<SearchScope, NoError>
    internal let presentSearchFilterViewController: Signal<SearchFilterViewController, NoError>
    internal let removeFilter: Signal<SearchFilterViewController, NoError>
    
    internal var inputs: SearchViewModelInputs { return self }
    internal var outputs: SearchViewModelOutputs { return self }
}
