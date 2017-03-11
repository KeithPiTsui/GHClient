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
    
    /// Call when user tapped on filter button
    func tappedFilterButton(within scope: SearchScope)
    
    /// Call when user pan on screen edge
    func screenEdgePan()
    
    /// Call when user tapped on dim view
    func tappedOnDimView()
    
    /// Call when user search
    func search(scope: SearchScope, keyword: String, qualifiers: [SearchQualifier])
    
    /// tap on user
    func goto(user: User)
}

internal protocol SearchViewModelOutputs {
    
    /// Emit a signal to update user data source, user search results
    var users: Signal<[User], NoError> { get }
    
    /// Emit a signal to update repository data source, repository search results
    var repositories: Signal<[Repository], NoError> {get}
    
    /// Emit a signal to specify search scopes, user and repository
    var searchScopes: Signal<[SearchScope], NoError> { get }
    
    /// Emit a signal to specify selected search scopes
    var selectedSearchScope: Signal<SearchScope, NoError> { get }
    
    /// Emit a signal to notify vc to present filter view controller
    var presentFilter: Signal<SearchFilterViewController, NoError> {get}
    
    /// Emit a signal to notify vc to remove filter view controller
    var removeFilter: Signal<SearchFilterViewController, NoError> {get}
    
    /// Emit a signal to specify the place holder of search bar
    var searchBarPlaceholder: Signal<String, NoError> {get}
    
}

internal protocol SearchViewModelType {
    var inputs: SearchViewModelInputs { get }
    var outputs: SearchViewModelOutputs { get }
}


internal final class SearchViewModel: SearchViewModelType, SearchViewModelInputs, SearchViewModelOutputs {

    
    init() {
        self.searchScopes = self.viewDidLoadProperty.signal.map {[SearchScope.userUnit, SearchScope.repositoryUnit]}
        
        let scopeSignal1 = self.viewDidLoadProperty.signal.map{SearchScope.userUnit}
        let scopeSignal2 = Signal.combineLatest(self.searchScopes, self.scopeSegmentChangedProperty.signal.skipNil()).map{$0[$1]}
        self.selectedSearchScope = Signal.merge(scopeSignal1, scopeSignal2)
        
        let filterViewController = self.viewDidLoadProperty.signal.map{_ in SearchFilterViewController.instantiate()}
        
        let filterPresented1 = self.tappedFilterButtonProperty.signal.skipNil().map{_ in true}
        let filterPresented2 = self.tappedOnDimViewProperty.signal.map{false}
        let filterPresented3 = self.screenEdgePanProperty.signal.map{true}
        let filterPresented4 = self.scopeSegmentChangedProperty.signal.skipNil().map{_ in false}
        let filterPresented = Signal.merge(filterPresented1, filterPresented2, filterPresented3, filterPresented4).skipRepeats()
        
        let filter = Signal.combineLatest(filterViewController, filterPresented)
        
        self.presentFilter = filter.filter{$0.1 == true}.map(first)
        
        self.removeFilter = filter.filter{$0.1 == false}.map(first)


        self.searchBarPlaceholder = self.selectedSearchScope.map { "Keyword about \($0.name)"}
        
        
        let search = self.searchProperty.signal.skipNil().observe(on: QueueScheduler())
                    .filter{$0.keyword.isEmpty == false}
        
        self.users = search
                    .filter{$0.scope == SearchScope.userUnit && $0.qualifiers is [UserQualifier]}
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
                            .filter{$0.scope == SearchScope.repositoryUnit && $0.qualifiers is [RepositoriesQualifier]}
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
    
    fileprivate let gotoUserProperty = MutableProperty<User?>(nil)
    internal func goto(user: User) {
        self.gotoUserProperty.value = user
    }
    
    fileprivate let screenEdgePanProperty = MutableProperty()
    internal func screenEdgePan() {
        self.screenEdgePanProperty.value = ()
    }
    
    fileprivate let tappedOnDimViewProperty = MutableProperty()
    internal func tappedOnDimView() {
        self.tappedOnDimViewProperty.value = ()
    }
    
    fileprivate let searchProperty = MutableProperty<(scope: SearchScope, keyword: String, qualifiers:[SearchQualifier])?>(nil)
    func search(scope: SearchScope, keyword: String, qualifiers: [SearchQualifier]){
        self.searchProperty.value = (scope, keyword, qualifiers)
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
    internal let presentFilter: Signal<SearchFilterViewController, NoError>
    internal let removeFilter: Signal<SearchFilterViewController, NoError>
    internal let searchBarPlaceholder: Signal<String, NoError>
    
    internal var inputs: SearchViewModelInputs { return self }
    internal var outputs: SearchViewModelOutputs { return self }
}
