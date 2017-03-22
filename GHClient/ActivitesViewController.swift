//
//  ActivitesViewController.swift
//  GHClient
//
//  Created by Pi on 08/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class ActivitesViewController: UIViewController {

  internal static func instantiate() -> ActivitesViewController {
    return Storyboard.Activities.instantiate(ActivitesViewController.self)
  }

  fileprivate let viewModel: ActivitesViewModelType = ActivitesViewModel()
  fileprivate let eventDatasource = ActivitesEventDatasource()

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var segment: UISegmentedControl!

  fileprivate let refreshControl = UIRefreshControl()

  @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
    self.viewModel.inputs.segmentChanged(index: sender.selectedSegmentIndex)
  }

  internal func set(initial segment: ActivitySegment) {
    self.viewModel.inputs.set(segment: segment)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = self.eventDatasource
    self.tableView.delegate = self
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
      self?.eventDatasource.load(events: $0)
      self?.tableView.reloadData()
    }
    self.viewModel.outputs.segments.observeForUI().observeValues { [weak self] in
      for (idx, seg) in $0.enumerated() {
        self?.segment.setTitle(seg.rawValue, forSegmentAt: idx)
      }
    }
    self.viewModel.outputs.selectedSegment.observeForUI().observeValues { [weak self] in
      self?.segment.selectedSegmentIndex = $0
    }
    self.viewModel.outputs.receivedEvents.observeForUI().observeValues { [weak self] in
      self?.eventDatasource.load(receivedEvents: $0)
      self?.tableView.reloadData()
    }
    self.viewModel.outputs.loading.observeForUI().observeValues { [weak self] in
      self?.refreshControl.beginRefreshing()
    }
    self.viewModel.outputs.loaded.observeForUI().observeValues { [weak self] in
      self?.refreshControl.endRefreshing()
    }
  }

  fileprivate var rowHeights: [IndexPath:CGFloat] = [:]

}

extension ActivitesViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if let h = rowHeights[indexPath] {
      return h
    }
    var height: CGFloat = 120
    if let value = self.eventDatasource[indexPath] as? GHEvent,
      let payload = value.payload {
      height = EventTableViewCell.estimatedHeight(with: payload)
    }
    rowHeights[indexPath] = height
    return height
  }
}

extension ActivitesViewController: TTTAttributedLabelDelegate {
  @objc func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
    print("\(url)")
  }
}





















