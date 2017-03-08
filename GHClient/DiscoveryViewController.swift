//
//  DiscoveryViewController.swift
//  GHClient
//
//  Created by Pi on 08/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

internal final class DiscoveryViewController: UIViewController {

    internal static func instantiate() -> DiscoveryViewController {
        return Storyboard.Discovery.instantiate(DiscoveryViewController.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
