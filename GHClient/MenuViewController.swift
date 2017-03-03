//
//  MenuViewController.swift
//  GHClient
//
//  Created by Pi on 02/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

final class MenuViewController: UITableViewController {

    internal static func instantiate() -> MenuViewController { return Storyboard.Menu.instantiate(MenuViewController.self)}
    
    fileprivate let viewModel: MenuViewModelType = MenuViewModel()
    fileprivate let datasource = MenuDataSource()
    
    @IBAction func tappedOnUserIcon(_ sender: UIBarButtonItem) {
        self.viewModel.inputs.tappedUserIcon()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self.datasource
        
        self.viewModel.inputs.viewDidLoad()
    }
    
    override func bindStyles() {
        super.bindStyles()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel.outpus.title.observeForUI().observeValues { [weak self] in
            self?.title = $0
            self?.navigationItem.title = $0
        }
        
        self.viewModel.outpus.presentViewController.observeForUI().observeValues{ [weak self] in
            self?.dismiss(animated: true, completion: nil)
            self?.present($0, animated: true, completion: nil)
        }
        
        self.viewModel.outpus.personalMenuItems.observeForUI().observeValues{ [weak self] in
            self?.datasource.load(personalItems: $0)
            self?.tableView.reloadData()
        }
        
        self.viewModel.outpus.discoveryMenuItems.observeForUI().observeValues{ [weak self] in
            self?.datasource.load(discoveryItems: $0)
            self?.tableView.reloadData()
        }
        
        self.viewModel.outpus.appMenuItems.observeForUI().observeValues{ [weak self] in
            self?.datasource.load(appItems: $0)
            self?.tableView.reloadData()
        }
    }
    
}
