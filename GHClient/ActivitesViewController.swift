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
    self.tableView.estimatedRowHeight = 80
    self.viewModel.inputs.viewDidLoad()
  }

  override func bindStyles() {
    super.bindStyles()
  }

  override func bindViewModel() {
    super.bindViewModel()
    self.viewModel.outputs.events.observeForUI().observeValues { [weak self] in
      self?.eventDatasource.load(watchings: $0)
      self?.tableView.reloadData()
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























