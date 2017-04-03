//
//  PullRequestTableViewController.swift
//  GHClient
//
//  Created by Pi on 03/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveExtensions
import ReactiveSwift
import ReactiveCocoa
import Result

internal final class PullRequestTableViewController: UITableViewController {

  internal static func instantiate() -> PullRequestTableViewController {
    return Storyboard.PullRequest.instantiate(PullRequestTableViewController.self)
  }

  fileprivate let viewModel: PullRequestViewModelType = PullRequestViewModel()
  fileprivate let datasource = PullRequestDatasource()

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
  }
}
