//
//  RepositoryIssuesTableViewController.swift
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

internal final class RepositoryIssuesTableViewController: UITableViewController {

  internal static func instantiate() -> RepositoryIssuesTableViewController {
    return Storyboard.RepositoryIssues.instantiate(RepositoryIssuesTableViewController.self)
  }

  fileprivate let viewModel: RepositoryIssuesViewModelType = RepositoryIssuesViewModel()
  fileprivate let datasource = RepositoryIssuesDatasource()

  internal func set(issues: [Issue], of repo: Repository) {
    self.viewModel.inputs.set(issues: issues, of: repo)
  }

  internal func set(issuesBelongTo repo: Repository) {
    self.viewModel.inputs.set(issuesBelongTo: repo)
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
    self.viewModel.outpus.issues.observeForUI().observeValues { [weak self] (issues) in
      self?.datasource.set(issues: issues)
      self?.tableView.reloadData()
    }
  }
}
