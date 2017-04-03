//
//  CommitTableViewController.swift
//  GHClient
//
//  Created by Pi on 30/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveExtensions
import ReactiveSwift
import ReactiveCocoa
import Result

internal final class CommitTableViewController: UITableViewController {

  internal static func instantiate() -> CommitTableViewController {
    return Storyboard.Commit.instantiate(CommitTableViewController.self)
  }

  fileprivate let viewModel: CommitViewModelType = CommitViewModel()
  fileprivate let datasource = CommitDatasource()

  internal func set(commit: Commit) {
    self.viewModel.inputs.set(commit: commit)
  }

  internal func set(commit: URL) {
    self.viewModel.inputs.set(commit: commit)
  }

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

    self.viewModel.outpus.commit.observeForUI().observeValues { [weak self] (commit) in
      self?.datasource.set(commitDesc: commit.commit.message)
      self?.tableView.reloadData()
    }

    self.viewModel.outpus.commitChanges.observeForUI().observeValues { [weak self] (files, changes) in
      self?.datasource.setCommitChanges(files: files, with: changes)
      self?.tableView.reloadData()
    }

    self.viewModel.outpus.commitComments.observeForUI().observeValues { [weak self] (comments) in
      self?.datasource.set(commitComments: comments)
      self?.tableView.reloadData()
    }
  }
}
