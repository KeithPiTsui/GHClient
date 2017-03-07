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
    func search(scope: SearchScope, keyword: String)
    
    /// Call when user tapped on filter button
    func tappedFilterButton(within scope: SearchScope)
}

internal protocol SearchViewModelOutputs {
    
    /// Emit a signal to update user data source
    var users: Signal<[User], NoError> { get }
    
    /// Emit a signal to update repository data source
    var repositories: Signal<[Repository], NoError> {get}
    
    /// Emit a signal to specify search scopes
    var searchScope: Signal<[SearchScope], NoError> { get }
    
    /// Emit a signal to specify selected search scopes
    var selectedSearchScope: Signal<SearchScope, NoError> { get }
    
    /// Emit a signal to notify vc to present a view controller
    var presentViewController: Signal<UIViewController, NoError> {get}
    
}

internal protocol SearchViewModelType {
    var inputs: SearchViewModelInputs { get }
    var outputs: SearchViewModelOutputs { get }
}


internal final class SearchViewModel: SearchViewModelType, SearchViewModelInputs, SearchViewModelOutputs {
    
    init() {
        self.searchScope = self.viewDidLoadProperty.signal.map {[.users([]), .repositories([]), .code([])]}
        
        self.users = self.usersProperty.signal.skipNil()
        self.repositories = self.repositoriesProperty.signal.skipNil()
        
        let scopeSignal1 = self.viewDidLoadProperty.signal.map{SearchScope.users([])}
        let scopeSignal2 = self.scopeSegmentChangedProperty.signal.skipNil()
            .map{ (idx) -> SearchScope in
                switch idx {
                case 0:
                    return .users([])
                case 1:
                    return .repositories([])
                case 2:
                    return .code([])
                default:
                    return .users([])
                }
            }
        self.selectedSearchScope = Signal.merge(scopeSignal1, scopeSignal2)
        
        self.presentViewController = self.tappedFilterButtonProperty.signal.skipNil().map {
            let vc = SearchFilterViewController.instantiate()
            vc.setFilterScope($0)
            return UINavigationController(rootViewController: vc)
        }
        
        self.searchProperty.signal.observe(on: QueueScheduler()).skipNil()
            .filter{$0.keyword.isEmpty == false && $0.scope == .users([])}
            .observeValues {
                let keyword = $0.keyword
                let uq = UserQualifier.type(.user)
                AppEnvironment.current.apiService
                    .searchUser(qualifiers: [uq], keyword: keyword, sort: .stars, order: .desc)
                    .startWithResult{ [weak self] result in
                        guard let value = result.value else { return }
                        self?.usersProperty.value = value.items
                    }
            }
        
        self.searchProperty.signal.observe(on: QueueScheduler()).skipNil()
            .filter{$0.keyword.isEmpty == false && $0.scope == .repositories([])}
            .observeValues {
                let keyword = $0.keyword
                let rq = RepositoriesQualifier.language([.swift])
                AppEnvironment.current.apiService
                    .searchRepository(qualifiers: [rq], keyword: keyword, sort: nil, order: nil)
                    .startWithResult{ [weak self] result in
                        guard let value = result.value else { return }
                        self?.repositoriesProperty.value = value.items
                }
            }
        
    }
    
    fileprivate let tappedFilterButtonProperty = MutableProperty<SearchScope?>(nil)
    internal func tappedFilterButton(within scope: SearchScope) {
        self.tappedFilterButtonProperty.value = scope
    }
    
    fileprivate let scopeSegmentChangedProperty = MutableProperty<Int?>(nil)
    internal func scopeSegmentChanged(index: Int) {
        self.scopeSegmentChangedProperty.value = index
    }
    
    fileprivate let searchProperty = MutableProperty<(scope: SearchScope, keyword: String)?>(nil)
    internal func search(scope: SearchScope, keyword: String) {
        self.searchProperty.value = (scope, keyword)
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
    
    fileprivate let usersProperty = MutableProperty<[User]?>(nil)
    fileprivate let repositoriesProperty = MutableProperty<[Repository]?>(nil)
    
    internal let users: Signal<[User], NoError>
    internal let repositories: Signal<[Repository], NoError>
    internal let searchScope: Signal<[SearchScope], NoError>
    internal let selectedSearchScope: Signal<SearchScope, NoError>
    internal let presentViewController: Signal<UIViewController, NoError>
    
    internal var inputs: SearchViewModelInputs { return self }
    internal var outputs: SearchViewModelOutputs { return self }
}
