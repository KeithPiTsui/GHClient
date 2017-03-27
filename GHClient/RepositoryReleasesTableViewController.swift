//
//  RepositoryReleasesTableViewController.swift
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

internal final class RepositoryReleasesTableViewController: UITableViewController {

  internal static func instantiate() -> RepositoryReleasesTableViewController {
    return Storyboard.RepositoryReleases.instantiate(RepositoryReleasesTableViewController.self)
  }

  fileprivate let viewModel: RepositoryReleasesViewModelType = RepositoryReleasesViewModel()
  fileprivate let datasource = RepositoryReleasesDatasource()

  internal func set(releases: [Release], of repo: Repository) {
    self.viewModel.inputs.set(releases: releases, of: repo)
  }

  internal func set(releasesBelongTo repo: Repository) {
    self.viewModel.inputs.set(releasesBelongTo: repo)
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
    self.viewModel.outpus.releases.observeForUI().observeValues { [weak self] (releases) in
      self?.datasource.set(releases: releases)
      self?.tableView.reloadData()
    }
  }
}
