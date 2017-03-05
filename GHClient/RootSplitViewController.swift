//
//  MainViewController.swift
//  GHClient
//
//  Created by Pi on 02/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

final class RootSplitViewController: UISplitViewController {
    
    
    fileprivate let viewModel: RootSplitViewModelType = RootSplitViewModel()
    fileprivate var masterWrapper: UINavigationController? { return self.viewControllers.first as? UINavigationController }
    fileprivate var detailWrapper: UINavigationController? { return self.viewControllers.last as? UINavigationController }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.viewModel.inputs.viewDidLoad()
        
    }

    internal override func bindStyles() {
        super.bindStyles()
    }
    
    /// Hanlding view model output signals
    internal override func bindViewModel() {
        super.bindViewModel()
        self.viewModel.outputs.setViewControllers.observeForUI().observeValues { [weak self] md in
            let master = UINavigationController(rootViewController: md.master)
            let detail = UINavigationController(rootViewController: md.detail)
            self?.viewControllers = [master, detail]
        }
    }
    
    
    
}

extension RootSplitViewController: UISplitViewControllerDelegate {

    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewControllerDisplayMode) {
        print("Hello")
    }
}

// MARK: -
// MARK: Go to other view controller

extension RootSplitViewController {
    internal func openMenu() {
        
    }
    
    internal func gotoUserProfile() {
        self.showDetailViewController(UserProfileViewController.instantiate(), sender: nil)
    }
    
    internal func gotoPersonalRepos() {
        
    }
    
    internal func gotoWatchedRepos() {
        
    }
    
    internal func gotoStarredRepos() {
        
    }
    
    internal func gotoIssuesRequests() {
        
    }
    
    internal func gotoPersonalGists() {
        
    }
    
    internal func gotoStarredGists() {
        
    }
    
    internal func gotoGists() {
        
    }
}





















