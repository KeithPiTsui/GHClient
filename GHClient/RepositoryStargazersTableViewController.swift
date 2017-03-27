//
//  RepositoryStargazersTableViewController.swift
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

internal final class RepositoryStargazersTableViewController: UITableViewController {

  internal static func instantiate() -> RepositoryStargazersTableViewController {
    return Storyboard.RepositoryStargazers.instantiate(RepositoryStargazersTableViewController.self)
  }

  fileprivate let viewModel: RepositoryStargazersViewModelType = RepositoryStargazersViewModel()
  fileprivate let datasource = RepositoryStargazersDatasource()

  internal func set(stargazers: [UserLite], of repo: Repository) {
    self.viewModel.inputs.set(stargazers: stargazers, of: repo)
  }

  internal func set(stargazersBelongTo repo: Repository) {
    self.viewModel.inputs.set(stargazersBelongTo: repo)
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
    self.viewModel.outpus.stargazers.observeForUI().observeValues { [weak self] (users) in
      self?.datasource.set(stargazers: users)
      self?.tableView.reloadData()
    }

  }
}
