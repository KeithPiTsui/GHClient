//
//  ReadmeViewModel.swift
//  GHClient
//
//  Created by Pi on 13/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import GHAPI
import Prelude


internal protocol ReadmeViewModelInputs {
    
    /// Call when the view did load.
    func viewDidLoad()
    
    /// Call when the view will appear with animated property.
    func viewWillAppear(animated: Bool)
    
    /// Call when a user session ends.
    func userSessionEnded()
    
    /// Call when a user session has started.
    func userSessionStarted()

    
    
    func set(readmeURL: URL)
    
}

internal protocol ReadmeViewModelOutputs {
    
    
    
    var navigateURL: Signal<URL, NoError> {get}
}

internal protocol ReadmeViewModelType {
    var inputs: ReadmeViewModelInputs { get }
    var outputs: ReadmeViewModelOutputs {get}
}

internal final class ReadmeViewModel: ReadmeViewModelType, ReadmeViewModelInputs, ReadmeViewModelOutputs {
    
    init() {
        self.navigateURL = Signal.combineLatest(self.setReadmeURL.signal.skipNil(), self.viewDidLoadProperty.signal).map(first)
    }
    
    fileprivate let setReadmeURL = MutableProperty<URL?>(nil)
    internal func set(readmeURL: URL) {
        self.setReadmeURL.value = readmeURL
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
    internal func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    fileprivate let viewWillAppearProperty = MutableProperty<Bool?>(nil)
    internal func viewWillAppear(animated: Bool) {
        self.viewWillAppearProperty.value = animated
    }
    
    internal let navigateURL: Signal<URL, NoError>
    
    internal var inputs: ReadmeViewModelInputs { return self }
    internal var outputs: ReadmeViewModelOutputs { return self }
}
