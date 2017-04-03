//
//  RepositoryCommitsTableViewController.swift
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

internal final class RepositoryCommitsTableViewController: UITableViewController {

  internal static func instantiate() -> RepositoryCommitsTableViewController {
    return Storyboard.RepositoryCommits.instantiate(RepositoryCommitsTableViewController.self)
  }

  fileprivate let viewModel: RepositoryCommitsViewModelType = RepositoryCommitsViewModel()
  fileprivate let datasource = RepositoryCommitsDatasource()

  internal func set(commits: [Commit], of repo: Repository, on branch: BranchLite) {
    self.viewModel.inputs.set(commits: commits, of: repo, on: branch)
  }

  internal func set(commitsBelongTo repo: Repository, on branch: BranchLite) {
    self.viewModel.inputs.set(commitsBelongTo: repo, on: branch)
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
    self.viewModel.outpus.commits.observeForUI().observeValues { [weak self] (commits) in
      self?.datasource.set(commits: commits)
      self?.tableView.reloadData()
    }
  }
}

extension RepositoryCommitsTableViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let commit = self.datasource[indexPath] as? Commit else { return }
    let vc = CommitTableViewController.instantiate()
    vc.set(commit: commit)
    self.navigationController?.pushViewController(vc, animated: true)
  }
}
















