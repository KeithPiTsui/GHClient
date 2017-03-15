//
//  ActivitiesViewModel.swift
//  GHClient
//
//  Created by Pi on 13/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import Foundation
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result
import GHAPI

internal enum ActivitySegment: String {
    case Watchings
    case Events
}

internal protocol ActivitesViewModelInputs {
    /// Call when a user session ends.
    func userSessionEnded()
    
    /// Call when a user session has started.
    func userSessionStarted()
    
    /// Call when the view did load.
    func viewDidLoad()
    
    /// Call when the view will appear with animated property.
    func viewWillAppear(animated: Bool)
    
    /// Call when user tap scope segment to change scope
    func segmentChanged(index: Int)
    
    /// Call when vc is set with an segment value
    func set(segment: ActivitySegment)
}

internal protocol ActivitesViewModelOutputs {
    
//    var segments: Signal<[ActivitySegment], NoError> { get }
//    
//    var selectedSegment: Signal<ActivitySegment, NoError> {get}
//    
    var events: Signal<[GHEvent], NoError> {get}
//
//    var watchings: Signal<[Watching], NoError> {get}
    
}

internal protocol ActivitesViewModelType {
    var inputs: ActivitesViewModelInputs { get }
    var outputs: ActivitesViewModelOutputs { get }
}

internal final class ActivitesViewModel: ActivitesViewModelType, ActivitesViewModelInputs, ActivitesViewModelOutputs {
    
    init() {
        self.events = self.viewDidLoadProperty.signal.observe(on: QueueScheduler()).map { () -> [GHEvent]? in
            guard let user = AppEnvironment.current.currentUser else { return nil }
            return AppEnvironment.current.apiService.events(of: user).single()?.value
        }.skipNil()
    }
    
    fileprivate let setSegmentProperty = MutableProperty<ActivitySegment?>(nil)
    internal func set(segment: ActivitySegment) {
        self.setSegmentProperty.value = segment
    }
    
    fileprivate let segmentChangedProperty = MutableProperty<Int?>(nil)
    internal func segmentChanged(index: Int) {
        self.segmentChangedProperty.value = index
    }
    
    fileprivate let userSessionStartedProperty = MutableProperty(())
    public func userSessionStarted() {
        self.userSessionStartedProperty.value = ()
    }
    fileprivate let userSessionEndedProperty = MutableProperty(())
    public func userSessionEnded() {
        self.userSessionEndedProperty.value = ()
    }
    
    fileprivate let viewDidLoadProperty = MutableProperty()
    public func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    fileprivate let viewWillAppearProperty = MutableProperty<Bool?>(nil)
    public func viewWillAppear(animated: Bool) {
        self.viewWillAppearProperty.value = animated
    }
    
    internal let events: Signal<[GHEvent], NoError>
    
    internal var inputs: ActivitesViewModelInputs { return self }
    internal var outputs: ActivitesViewModelOutputs { return self }
}
