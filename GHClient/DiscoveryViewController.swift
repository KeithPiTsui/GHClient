//
//  DiscoveryViewController.swift
//  GHClient
//
//  Created by Pi on 08/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import Prelude
import Prelude_UIKit
import ReactiveSwift
import ReactiveCocoa
import Result
import GHAPI

internal final class DiscoveryViewController: UIViewController {

    internal static func instantiate() -> DiscoveryViewController {
        return Storyboard.Discovery.instantiate(DiscoveryViewController.self)
    }
    
    fileprivate let viewModel: DiscoveryViewModelType = DiscoveryViewModel()
    fileprivate let datasource = DiscoveryDatasource()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self.datasource
        self.tableView.delegate = self
        
        self.viewModel.inputs.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.inputs.viewWillAppear(animated: animated)
    }
    
    override func bindStyles() {
        super.bindStyles()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        self.viewModel.outputs.repositories.observeForUI().observeValues { [weak self] (repos) in
            self?.datasource.load(repos: repos)
            self?.tableView.reloadData()
        }
    }
}


extension DiscoveryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}





























