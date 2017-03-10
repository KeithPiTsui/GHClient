//
//  SearchFilterViewModel.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result
import Curry
import Argo
import Runes
import GHAPI
import Prelude


internal protocol SearchFilterViewModelInputs {
    /// Call when the view did load.
    func viewDidLoad()
    
    /// Call when the view will appear with animated property.
    func viewWillAppear(animated: Bool)
    
    /// Call when a user session ends.
    func userSessionEnded()
    
    /// Call when a user session has started.
    func userSessionStarted()
    
    /// Call when set filter scope
    func set(filterScope: SearchScope)
    
    /// Call when specify user qualifiers
    func specify(qualifiers: [SearchQualifier])
    
}

internal protocol SearchFilterViewModelOutputs{
    
    var filterScope: Signal<SearchScope, NoError> {get}
    
    /// Emit a signal containing User search qualifier package to set up user search qualifier
    var userSearchQualifierPackage: Signal<UserSearchQualifierOptions, NoError> { get }
    
    /// Emit a signal containing Repository search qualifier package to set up repository search qualifier
    var repositorySearchQualifierPackage: Signal<RepositorySearchQualifierOptions, NoError> {get}
    
    /// Emit a signal specifying preset search qualifiers for user search
    var userSearchQualifiers: Signal<[UserQualifier], NoError> { get }
    
    /// Emit a signal specifying preset search qualifiers for repository search
    var repositorySearchQualifiers: Signal<[RepositoriesQualifier], NoError> {get}
    
}

internal protocol SearchFilterViewModelType{
    var inputs: SearchFilterViewModelInputs {get}
    var outputs: SearchFilterViewModelOutputs {get}
}

internal final class SearchFilterViewModel: SearchFilterViewModelType, SearchFilterViewModelInputs, SearchFilterViewModelOutputs {
    
    init() {
        
        let userSQP = self.viewDidLoadProperty.signal.map {
            UserSearchQualifierOptions(userTypes: UserType.allCases,
                                       userInArguments: UserInArgument.allCases,
                                       reposRange: .none,
                                       city: "",
                                       programmingLanguages: LanguageArgument.allCases,
                                       createdDateRange: .none,
                                       followersRange: .none)}
        
        self.userSearchQualifierPackage = Signal.combineLatest(userSQP, self.setScope.signal.skipNil())
            .filter{$0.1 == SearchScope.userUnit}
            .map(first)
        
        let repoSQP = self.viewDidLoadProperty.signal.map {
            RepositorySearchQualifierOptions(searchIn: RepositoriesInArgument.allCases,
                                             size: .none,
                                             forks: .none,
                                             fork: RepositoriesForkArgument.allCases,
                                             created: .none,
                                             pushed: .none,
                                             user: "",
                                             language: LanguageArgument.allCases,
                                             star: .none)
        }
        
        self.repositorySearchQualifierPackage = Signal.combineLatest(repoSQP, self.setScope.signal.skipNil())
            .filter{$0.1 == SearchScope.repositoryUnit}
            .map(first)
        
        self.filterScope = self.setScope.signal.skipNil()
        
        let uq = self.specifiedQualifiersProperty.signal.map{$0 as? [UserQualifier]}.skipNil()
        
        self.userSearchQualifiers = Signal.combineLatest(uq, self.viewWillAppearProperty.signal).map(first)
        
        let rq = self.specifiedQualifiersProperty.signal.map{$0 as? [RepositoriesQualifier]}.skipNil()
        
        self.repositorySearchQualifiers = Signal.combineLatest(rq, self.viewWillAppearProperty.signal).map(first)
    }
    
    fileprivate let specifiedQualifiersProperty = MutableProperty<[SearchQualifier]>([])
    internal func specify(qualifiers: [SearchQualifier]) {
        self.specifiedQualifiersProperty.value = qualifiers
    }
    
    fileprivate let setScope = MutableProperty<SearchScope?>(nil)
    internal func set(filterScope: SearchScope) {
        self.setScope.value = filterScope
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
    
    /// Emit a signal containing User search qualifier package to set up user search qualifier
    internal let userSearchQualifierPackage: Signal<UserSearchQualifierOptions, NoError>
    
    /// Emit a signal containing Repository search qualifier package to set up repository search qualifier
    internal let repositorySearchQualifierPackage: Signal<RepositorySearchQualifierOptions, NoError>
    
    /// Emit a signal specifying preset search qualifiers for user search
    internal let userSearchQualifiers: Signal<[UserQualifier], NoError>
    
    /// Emit a signal specifying preset search qualifiers for repository search
    internal let repositorySearchQualifiers: Signal<[RepositoriesQualifier], NoError>
    
    internal let filterScope: Signal<SearchScope, NoError>
    
    internal var inputs: SearchFilterViewModelInputs { return self }
    internal var outputs: SearchFilterViewModelOutputs { return self }
}
