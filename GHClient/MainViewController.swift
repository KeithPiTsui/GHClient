//
//  MainViewController.swift
//  GHClient
//
//  Created by Pi on 02/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

final class MainViewController: UISplitViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self

        // Do any additional setup after loading the view.
    }

}

extension MainViewController: UISplitViewControllerDelegate {
    
}
