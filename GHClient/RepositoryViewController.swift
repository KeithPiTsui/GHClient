//
//  RepositoryViewController.swift
//  GHClient
//
//  Created by Pi on 11/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class RepositoryViewController: UIViewController {

  internal static func instantiate() -> RepositoryViewController {
    return Storyboard.Repository.instantiate(RepositoryViewController.self)
  }

  fileprivate let viewModel: RepositoryViewModelType = RepositoryViewModel()
  fileprivate let datasource = RepositoryDatasource()

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var repoIcon: UIImageView!
  @IBOutlet weak var repoName: UILabel!
  @IBOutlet weak var stars: UILabel!
  @IBOutlet weak var forks: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = self.datasource
    self.tableView.delegate = self
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 120
    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear(animated: animated)
  }


  internal func set(repo: Repository) {
    self.viewModel.inputs.set(repo: repo)
  }

  internal func set(repoURL: URL) {
    self.viewModel.inputs.set(repoURL: repoURL)
  }

  override func bindStyles() {
    super.bindStyles()
  }

  override func bindViewModel() {
    super.bindViewModel()
    self.viewModel.outputs.repository.observeForUI().observeValues { [weak self] (repo) in
      self?.repoName.text = repo.name
      self?.stars.text = "\(repo.stargazers_count)"
      self?.forks.text = "\(repo.others.forks_count)"
    }

    self.viewModel.outputs.branchLites.observeForUI().observeValues { [weak self] (branchLites) in
      self?.datasource.set(branchLites: branchLites)
      self?.datasource.setCommit(on: branchLites)
      self?.tableView.reloadData()
    }

    self.viewModel.outputs.brief.observeForUI().observeValues { [weak self] in
      self?.datasource.setBrief(a: $0.a, b: $0.b, c: $0.c, d: $0.d)
      self?.tableView.reloadData()
    }

    self.viewModel.outputs.details.observeForUI().observeValues { [weak self] in
      self?.datasource.setDetailDiveIn(values: $0)
      self?.tableView.reloadData()
    }
    self.viewModel.outputs.gotoReadmeVC.observeForControllerAction().observeValues { [weak self] in
      self?.navigationController?.pushViewController($0, animated: true)
    }
    self.viewModel.outputs.gotoBranchVC.observeForControllerAction().observeValues { [weak self] in
      self?.navigationController?.pushViewController($0, animated: true)
    }
  }

}

extension RepositoryViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 0 && indexPath.row == 2 {
      self.viewModel.inputs.gotoReadme()
    }
    if indexPath.section == 2, let branchLite = self.datasource[indexPath] as? BranchLite {
      self.viewModel.inputs.goto(branch: branchLite)
    }
  }

}



























