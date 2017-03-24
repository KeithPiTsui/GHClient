//
//  IssueTableViewController.swift
//  GHClient
//
//  Created by Pi on 24/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class IssueTableViewController: UITableViewController {

  internal static func instantiate() -> IssueTableViewController {
    return Storyboard.Issue.instantiate(IssueTableViewController.self)
  }

  fileprivate let viewModel: IssueViewModelType = IssueViewModel()
  fileprivate let datasource = IssueDatasource()

  @IBOutlet weak var issueIcon: UIImageView!
  @IBOutlet weak var issueTitle: UILabel!

  internal func set(issue url: URL) {
    self.viewModel.inputs.set(issue: url)
  }

  internal func set(issue: Issue) {
    self.viewModel.inputs.set(issue: issue)
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
    self.viewModel.outpus.issue.observeForUI().observeValues { [weak self] in
      self?.datasource.load(issue: $0)
      self?.issueTitle.text = $0.title
      self?.sizeHeaderToFit()
      self?.tableView.reloadData()
    }
    self.viewModel.outpus.issueComments.observeForUI().observeValues { [weak self] in
      self?.datasource.loadd(issueComments: $0)
      self?.tableView.reloadData()
    }
  }

  private func sizeHeaderToFit() {
    guard let headerView = tableView.tableHeaderView else { return }
    headerView.setNeedsLayout()
    headerView.layoutIfNeeded()
    let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    var frame = headerView.frame
    frame.size.height = height
    headerView.frame = frame
    self.tableView.tableHeaderView = headerView
  }
}

extension IssueTableViewController {
  
}







































