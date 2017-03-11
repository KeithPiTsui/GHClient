//
//  RepositoryViewModel.swift
//  GHClient
//
//  Created by Pi on 11/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import GHAPI
import Prelude

internal protocol RepositoryViewModelInputs {
    /// Call when the view did load.
    func viewDidLoad()
    
    /// Call when the view will appear with animated property.
    func viewWillAppear(animated: Bool)
    
    /// Call when a user session ends.
    func userSessionEnded()
    
    /// Call when a user session has started.
    func userSessionStarted()
    
    /// Call when vc receive a repository to display
    func set(repo: Repository)
    
    /// Call when vc receive a url to repository for display
    func set(repoURL: URL)
}

internal protocol RepositoryViewModelOutputs {
    
    
    var repository: Signal<Repository,NoError> { get }
}

internal protocol RepositoryViewModelType {
    var inputs: RepositoryViewModelInputs { get }
    var outputs: RepositoryViewModelOutputs { get }
}

internal final class RepositoryViewModel: RepositoryViewModelType, RepositoryViewModelInputs, RepositoryViewModelOutputs {
    
    init() {
        let repo1 = self.setRepoURLProperty.signal.skipNil()
            .map {AppEnvironment.current.apiService.repository(referredBy: $0).single()}
            .map {$0?.value}.skipNil()
        let repo2 = self.setRepoProperty.signal.skipNil()
        let repo = Signal.merge(repo1, repo2)
        let repoDisplay = Signal.combineLatest(repo, self.viewDidLoadProperty.signal).map(first)
        
        self.repository = repoDisplay
    }
    
    fileprivate let setRepoProperty = MutableProperty<Repository?>(nil)
    public func set(repo: Repository) {
        self.setRepoProperty.value = repo
    }
    
    fileprivate let setRepoURLProperty = MutableProperty<URL?>(nil)
    public func set(repoURL: URL) {
        self.setRepoURLProperty.value = repoURL
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
    
    
    internal let repository: Signal<Repository, NoError>
    
    internal var inputs: RepositoryViewModelInputs { return self }
    internal var outputs: RepositoryViewModelOutputs { return self }
}
