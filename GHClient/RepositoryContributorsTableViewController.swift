//
//  RepositoryContributorsTableViewController.swift
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

internal final class RepositoryContributorsTableViewController: UITableViewController {

  internal static func instantiate() -> RepositoryContributorsTableViewController {
    return Storyboard.RepositoryContributors.instantiate(RepositoryContributorsTableViewController.self)
  }

  fileprivate let viewModel: RepositoryContributorsViewModelType = RepositoryContributorsViewModel()
  fileprivate let datasource = RepositoryContributorsDatasource()

  internal func set(contributors: [UserLite], of repo: Repository) {
    self.viewModel.inputs.set(contributors: contributors, of: repo)
  }

  internal func set(contributorsBelongTo repo: Repository) {
    self.viewModel.inputs.set(contributorsBelongTo: repo)
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
    self.viewModel.outpus.contributors.observeForUI().observeValues { [weak self] (users) in
      self?.datasource.set(contributors: users)
      self?.tableView.reloadData()
    }

  }
}
