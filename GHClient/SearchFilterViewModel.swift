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
import GHAPI

internal protocol SearchFilterViewModelInputs {
    /// Call when the view did load.
    func viewDidLoad()
    
    /// Call when the view will appear with animated property.
    func viewWillAppear(animated: Bool)
    
    /// Call when a user session ends.
    func userSessionEnded()
    
    /// Call when a user session has started.
    func userSessionStarted()
}

internal protocol SearchFilterViewModelOutputs{
    
    /// Emit a signal for options of user types
    var userTypes: Signal<[UserType],NoError> { get }
    
    /// Emit a signal for options of search fields
    var searchFields: Signal<[UserInArgument], NoError> {get}
    
    /// Emit a signal for options of Repos Range
    var reposRange: Signal<NumberRange, NoError> { get}
    
    /// Emit a signal for options of cities
    var cities: Signal<[String], NoError> {get}
    
    /// Emit a signal for options of languages
    var languages: Signal<[LanguageArgument], NoError> {get}
    
    /// Emit a signal for options of created date range
    var createdDateRange: Signal<DateRange, NoError> { get }
    
    /// Emit a signal for options of followers range
    var followersRange: Signal<NumberRange, NoError> {get}
}

internal protocol SearchFilterViewModelType{
    var inputs: SearchFilterViewModelInputs {get}
    var outputs: SearchFilterViewModelOutputs {get}
}

internal final class SearchFilterViewModel: SearchFilterViewModelType, SearchFilterViewModelInputs, SearchFilterViewModelOutputs {
    
    init() {
        self.userTypes = self.viewDidLoadProperty.signal.map{return [UserType.user, UserType.org]}
        self.searchFields = self.viewDidLoadProperty.signal.map{return [UserInArgument.name, UserInArgument.readme]}
        self.reposRange = self.viewDidLoadProperty.signal.map{return (nil, nil)}
        self.cities = self.viewDidLoadProperty.signal.map{return ["Guangzhou", "HongKong"]}
        self.languages = self.viewDidLoadProperty.signal.map{[LanguageArgument.assembly, LanguageArgument.swift]}
        self.createdDateRange = self.viewDidLoadProperty.signal.map{return (nil, nil)}
        self.followersRange = self.viewDidLoadProperty.signal.map{return (nil, nil)}
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
    
    internal let userTypes: Signal<[UserType], NoError>
    internal let searchFields: Signal<[UserInArgument], NoError>
    internal let reposRange: Signal<NumberRange, NoError>
    internal let cities: Signal<[String], NoError>
    internal let languages: Signal<[LanguageArgument], NoError>
    internal let createdDateRange: Signal<DateRange, NoError>
    internal let followersRange: Signal<NumberRange, NoError>
    
    internal var inputs: SearchFilterViewModelInputs { return self }
    internal var outputs: SearchFilterViewModelOutputs { return self }
}
