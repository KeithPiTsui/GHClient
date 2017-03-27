//
//  PullRequestsTableViewController.swift
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

internal final class PullRequestsTableViewController: UITableViewController {

  internal static func instantiate() -> PullRequestsTableViewController {
    return Storyboard.PullRequests.instantiate(PullRequestsTableViewController.self)
  }

  fileprivate let viewModel: PullRequestsViewModelType = PullRequestsViewModel()
  fileprivate let datasource = PullRequestsDatasource()

  internal func set(pullRequests: [PullRequest], of repo: Repository) {
    self.viewModel.inputs.set(pullRequests: pullRequests, of: repo)
  }

  internal func set(pullRequestsBelongTo repo: Repository) {
    self.viewModel.inputs.set(pullRequestsBelongTo: repo)
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
    self.viewModel.outpus.pullRequests.observeForUI().observeValues { [weak self] (prs) in
      self?.datasource.set(pullRequests: prs)
      self?.tableView.reloadData()
    }
  }
}
