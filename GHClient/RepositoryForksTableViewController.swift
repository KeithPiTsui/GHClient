//
//  RepositoryForksTableViewController.swift
//  GHClient
//
//  Created by Pi on 27/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveExtensions
import ReactiveSwift
import ReactiveCocoa
import Result

internal final class RepositoryForksTableViewController: UITableViewController {

  internal static func instantiate() -> RepositoryForksTableViewController {
    return Storyboard.RepositoryForks.instantiate(RepositoryForksTableViewController.self)
  }

  fileprivate let viewModel: RepositoryForksViewModelType = RepositoryForksViewModel()
  fileprivate let datasource = RepositoryForksDatasource()

  internal func set(forks: [Repository], of repo: Repository) {
    self.viewModel.inputs.set(forks: forks, of: repo)
  }

  internal func set(forksBelongTo repo: Repository) {
    self.viewModel.inputs.set(forksBelongTo: repo)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = self.datasource
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
    self.viewModel.outpus.forks.observeForUI().observeValues { [weak self] (forks) in
      self?.datasource.set(forks: forks)
      self?.tableView.reloadData()
    }
  }
}
