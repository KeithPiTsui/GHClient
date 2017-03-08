//
//  RootTabBarViewController.swift
//  GHClient
//
//  Created by Pi on 08/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import Prelude
import ReactiveSwift
import Result
import ReactiveCocoa

internal final class RootTabBarViewController: UITabBarController {

    fileprivate let viewModel: RootTabBarViewModelType = RootTabBarViewModel()
    
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        NotificationCenter
            .default
            .addObserver(forName: Notification.Name.gh_sessionStarted, object: nil, queue: nil) { [weak self] _ in
                self?.viewModel.inputs.userSessionStarted()
        }
        
        NotificationCenter
            .default
            .addObserver(forName: Notification.Name.gh_sessionEnded, object: nil, queue: nil) { [weak self] _ in
                self?.viewModel.inputs.userSessionEnded()
        }
        
        NotificationCenter
            .default
            .addObserver(forName: Notification.Name.gh_userUpdated, object: nil, queue: nil) { [weak self] _ in
                self?.viewModel.inputs.currentUserUpdated()
        }
        
        self.viewModel.inputs.viewDidLoad()
    }
    
    override func bindStyles() {
        super.bindStyles()
        _ = self.tabBar
            |> UITabBar.lens.tintColor .~ tabBarSelectedColor
            |> UITabBar.lens.barTintColor .~ tabBarTintColor
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel.outputs.setViewControllers
            .observeForUI()
            .observeValues { [weak self] in self?.setViewControllers($0, animated: false) }
        
        self.viewModel.outputs.selectedIndex
            .observeForUI()
            .observeValues { [weak self] in self?.selectedIndex = $0 }
        
//        self.viewModel.outputs.scrollToTop
//            .observeForUI()
//            .observeValues(scrollToTop)
        
//        self.viewModel.outputs.tabBarItemsData
//            .observeForUI()
//            .observeValues { [weak self] in self?.setTabBarItemStyles(withData: $0) }
//
//        self.viewModel.outputs.filterDiscovery
//            .observeForUI()
//            .observeValues { $0.filter(with: $1) }
        
        self.viewModel.outputs.tabBarItemsData
            .observeForUI()
            .observeValues { [weak self] in self?.setTabBarItemStyles(withData: $0) }
//        

    }
    
    fileprivate func setTabBarItemStyles(withData data: [String]) {
        for (idx, str) in data.enumerated() {
            self.tabBarItem(atIndex: idx)?.title = str
        }
    }
    
    fileprivate func tabBarItem(atIndex index: Int) -> UITabBarItem? {
        if (self.tabBar.items?.count ?? 0) > index {
            if let item = self.tabBar.items?[index] {
                return item
            }
        }
        return nil
    }
    
}

extension RootTabBarViewController: UITabBarControllerDelegate {
    
}
