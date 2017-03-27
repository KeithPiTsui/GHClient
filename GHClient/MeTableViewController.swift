//
//  MeTableViewController.swift
//  GHClient
//
//  Created by Pi on 23/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

internal final class MeTableViewController: UITableViewController {

  internal static func instantiate() -> MeTableViewController {
    return Storyboard.Me.instantiate(MeTableViewController.self)
  }

  fileprivate let viewModel: MeViewModelType = MeViewModel()
  fileprivate let datasource = MeDatasource()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = self.datasource
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 120
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
    self.viewModel.outpus.user.observeForUI().observeValues { [weak self] (user) in
      self?.datasource.set(userBrief: user)
      self?.tableView.reloadData()
      DispatchQueue.main.async {
        self?.viewModel.inputs.briefSetupCompleted()
      }
    }

    self.viewModel.outpus.personalRepositories.observeForUI().observeValues { [weak self] (repos) in
      self?.datasource.set(personalRepos: repos)
      self?.tableView.reloadData()
    }

    self.viewModel.outpus.starredRepositories.observeForUI().observeValues { [weak self] (repos) in
      self?.datasource.set(starredRepos: repos)
      self?.tableView.reloadData()
    }
  }
}
