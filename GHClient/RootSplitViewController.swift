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
            self?.viewControllers = [md.master, md.detail]
        }
        
    }
    
}

extension RootSplitViewController: UISplitViewControllerDelegate {
    
}
