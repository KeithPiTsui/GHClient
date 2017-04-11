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
import TTTAttributedLabel

internal final class PullRequestTableViewController: UITableViewController {

  internal static func instantiate() -> PullRequestTableViewController {
    return Storyboard.PullRequest.instantiate(PullRequestTableViewController.self)
  }

  fileprivate let viewModel: PullRequestViewModelType = PullRequestViewModel()
  fileprivate let datasource = PullRequestDatasource()

  @IBOutlet weak var pullRequestAvatar: UIImageView!
  @IBOutlet weak var pullRequestTitle: UILabel!

  internal func set(pullRequest: PullRequest) {
    self.viewModel.inputs.set(pullRequest: pullRequest)
  }

  internal func set(pullRequest: URL) {
    self.viewModel.inputs.set(pullRequest: pullRequest)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = self.datasource
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 120
    self.pullRequestAvatar.tintColor = UIColor.green
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
    self.viewModel.outpus.pullRequest.observeForUI().observeValues { [weak self] in
      self?.pullRequestTitle.text = $0.title
      self?.datasource.set(pullRequest: $0)
      self?.tableView.reloadData()
    }

    self.viewModel.outpus.commemts.observeForUI().observeValues { [weak self] in
      self?.datasource.set(comments: $0)
      self?.tableView.reloadData()
    }
  }
}

extension PullRequestTableViewController {
  internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    let value = self.datasource[indexPath]
  }
}

extension PullRequestTableViewController: TTTAttributedLabelDelegate {
  @objc func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
    print("\(url)")

  }
}















