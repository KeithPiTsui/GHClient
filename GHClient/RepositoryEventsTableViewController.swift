//
//  RepositoryEventsTableViewController.swift
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

internal final class RepositoryEventsTableViewController: UITableViewController {

  internal static func instantiate() -> RepositoryEventsTableViewController {
    return Storyboard.RepositoryEvents.instantiate(RepositoryEventsTableViewController.self)
  }

  fileprivate let viewModel: RepositoryEventsViewModelType = RepositoryEventsViewModel()
  fileprivate let datasource = RepositoryEventsDatasource()

  internal func set(events: [GHEvent], of repo: Repository) {
    self.viewModel.inputs.set(events: events, of: repo)
  }

  internal func set(eventsBelongTo repo: Repository)  {
    self.viewModel.inputs.set(eventsBelongTo: repo)
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
    self.viewModel.outpus.events.observeForUI().observeValues { [weak self] (events) in
      self?.datasource.set(events: events)
      self?.tableView.reloadData()
    }
  }
}
