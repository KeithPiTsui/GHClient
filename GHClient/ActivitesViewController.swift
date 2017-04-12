//
//  ActivitesViewController.swift
//  GHClient
//
//  Created by Pi on 08/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveExtensions
import ReactiveSwift
import ReactiveCocoa
import Result
import TTTAttributedLabel

internal final class ActivitesViewController: UIViewController {

  internal static func instantiate() -> ActivitesViewController {
    return Storyboard.Activities.instantiate(ActivitesViewController.self)
  }

  fileprivate let viewModel: ActivitesViewModelType = ActivitesViewModel()
  fileprivate let datasource = EventDatasource()
  fileprivate let redatasource = EventDatasource()
  fileprivate let refreshControl = UIRefreshControl()

  fileprivate var selectedDatasource: EventDatasource {
    if self.segment.selectedSegmentIndex == 0 {
      return self.datasource
    } else {
      return self.redatasource
    }
  }

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var segment: UISegmentedControl!

  @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
    self.viewModel.inputs.segmentChanged(index: sender.selectedSegmentIndex)
  }

  internal func set(initial segment: ActivitySegment) {
    self.viewModel.inputs.set(segment: segment)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = self.datasource
    self.tableView.delegate = self
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 120
    self.refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    if #available(iOS 10.0, *) {
      self.tableView.refreshControl = self.refreshControl
    } else {
      self.tableView.backgroundView = self.refreshControl
    }
    self.viewModel.inputs.viewDidLoad()
  }

  func refresh(_ refreshControl: UIRefreshControl) {
    self.viewModel.inputs.refreshEvents()
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
    self.viewModel.outputs.events.observeForUI().observeValues { [weak self] in
      self?.datasource.load(events: $0)
      self?.tableView.reloadData()
    }
    self.viewModel.outputs.receivedEvents.observeForUI().observeValues { [weak self] in
      self?.redatasource.load(events: $0)
      self?.tableView.reloadData()
    }

    self.viewModel.outputs.selectedSegment.observeForUI().observeValues { [weak self] in
      self?.segment.selectedSegmentIndex = $0
      if $0 == 0 {
        self?.tableView.dataSource = self?.datasource
      } else if $0 == 1 {
        self?.tableView.dataSource = self?.redatasource
      }
      self?.tableView.reloadData()
    }

    self.viewModel.outputs.segments.observeForUI().observeValues { [weak self] in
      for (idx, seg) in $0.enumerated() {
        self?.segment.setTitle(seg.rawValue, forSegmentAt: idx)
      }
    }

    self.viewModel.outputs.loading.observeForUI().observeValues { [weak self] in
      self?.refreshControl.beginRefreshing()
    }
    self.viewModel.outputs.loaded.observeForUI().observeValues { [weak self] in
      self?.refreshControl.endRefreshing()
    }
    self.viewModel.outputs.pushViewController.observeForControllerAction().observeValues { [weak self] in
      self?.navigationController?.pushViewController($0, animated: true)
    }
  }
}

extension ActivitesViewController: UITableViewDelegate {
  internal func tableView(_ tableView: UITableView,
                                   willDisplay cell: UITableViewCell,
                                   forRowAt indexPath: IndexPath) {
    self.viewModel.inputs.willDisplayRow(self.datasource.itemIndexAt(indexPath),
                                         outOf: self.datasource.numberOfItems())
  }
}

extension ActivitesViewController: TTTAttributedLabelDelegate {
  @objc func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
    print("\(url)")
    guard
      let cell = label.tableViewCell,
      let indexPath = self.tableView.indexPath(for: cell),
      let event = self.datasource[indexPath] as? GHEvent
    else { return }
    self.viewModel.inputs.tapped(on: event, with: url)
  }
}



















