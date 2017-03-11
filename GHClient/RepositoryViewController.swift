//
//  RepositoryViewController.swift
//  GHClient
//
//  Created by Pi on 11/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class RepositoryViewController: UIViewController {

    internal static func instantiate() -> RepositoryViewController {
        return Storyboard.Repository.instantiate(RepositoryViewController.self)
    }
    
    fileprivate let viewModel: RepositoryViewModelType = RepositoryViewModel()
    fileprivate let datasource = RepositoryDatasource()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var repoIcon: UIImageView!
    @IBOutlet weak var repoName: UILabel!
    @IBOutlet weak var stars: UILabel!
    @IBOutlet weak var forks: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self.datasource
        self.tableView.delegate = self
        self.viewModel.inputs.viewDidLoad()
    }
    
    
    internal func set(repo: Repository) {
        
    }
    
    internal func set(repoURL: URL) {
        
    }
    
    override func bindStyles() {
        super.bindStyles()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
    }
    
}

extension RepositoryViewController: UITableViewDelegate {
    
}
