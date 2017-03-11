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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.inputs.viewWillAppear(animated: animated)
    }
    
    
    internal func set(repo: Repository) {
        self.viewModel.inputs.set(repo: repo)
    }
    
    internal func set(repoURL: URL) {
        self.viewModel.inputs.set(repoURL: repoURL)
    }
    
    override func bindStyles() {
        super.bindStyles()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        self.viewModel.outputs.repository.observeForUI().observeValues { [weak self] (repo) in
            self?.repoName.text = repo.name
            self?.stars.text = "\(repo.stargazers_count)"
            self?.forks.text = "\(repo.forks_count)"
        }
        
        self.viewModel.outputs.branches.observeForUI().observeValues { [weak self] (branches) in
            self?.datasource.set(branches: branches)
            self?.datasource.setCommit(on: branches)
            self?.tableView.reloadData()
        }
        
        self.viewModel.outputs.brief.observeForUI().observeValues { [weak self] in
            self?.datasource.setBrief(a: $0.a, b: $0.b, c: $0.c, d: $0.d)
            self?.tableView.reloadData()
        }
        
        self.viewModel.outputs.details.observeForUI().observeValues { [weak self] in
            self?.datasource.setDetailDiveIn(values: $0)
            self?.tableView.reloadData()
        }
        
    }
    
}

extension RepositoryViewController: UITableViewDelegate {
    
}
