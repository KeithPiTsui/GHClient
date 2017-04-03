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
    self.viewModel.outputs.repository.observeForControllerAction().observeValues { [weak self] (repo) in
      self?.repoName.text = repo.name
      self?.stars.text = "\(repo.stargazers_count)"
      self?.forks.text = "\(repo.others.forks_count)"
      DispatchQueue.main.async {
        self?.datasource.set(repo: repo)
        self?.tableView.reloadData()
        self?.viewModel.inputs.datasourceInitialized()
      }
    }

    self.viewModel.outputs.branchLites.observeForControllerAction().observeValues { [weak self] (branchLites) in
      self?.datasource.set(branchLites: branchLites)
      self?.datasource.setCommit(on: branchLites)
      self?.tableView.reloadData()
    }

    self.viewModel.outputs.repoReadme.observeForControllerAction().observeValues { [weak self] (readme) in
      self?.datasource.set(readme: readme)
    }

    self.viewModel.outputs.repoForks.observeForControllerAction().observeValues { [weak self] (forks) in
      self?.datasource.set(forks: forks)
    }

    self.viewModel.outputs.repoReleases.observeForControllerAction().observeValues { [weak self] (releases) in
      self?.datasource.set(release: releases)
    }

    self.viewModel.outputs.repoActivities.observeForControllerAction().observeValues { [weak self] (activities) in
      self?.datasource.set(activities: activities)
    }

    self.viewModel.outputs.repoContributors.observeForControllerAction().observeValues { [weak self] (contributors) in
      self?.datasource.set(contributors: contributors)
    }

    self.viewModel.outputs.repoStargazers.observeForControllerAction().observeValues { [weak self] (stargazers) in
      self?.datasource.set(stargazers: stargazers)
    }

    self.viewModel.outputs.repoPullRequests.observeForControllerAction().observeValues { [weak self] (pullRequests) in
      self?.datasource.set(pullRequests: pullRequests)
    }

    self.viewModel.outputs.repoIssues.observeForControllerAction().observeValues { [weak self] (issues) in
      self?.datasource.set(issues: issues)
    }

    self.viewModel.outputs.pushViewController.observeForControllerAction().observeValues { [weak self] in
      self?.navigationController?.pushViewController($0, animated: true)
    }

    self.viewModel.outputs.popupViewController.observeForControllerAction().observeValues { [weak self] in
      self?.dismiss(animated: true, completion: nil)
      self?.present($0, animated: true, completion: nil)
    }
  }
}

extension RepositoryViewController: UITableViewDelegate {

  internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let value = self.datasource[indexPath]
    if let owner = value as? UserLite {
      self.viewModel.inputs.click(repoOwner: owner)
      return
    }
    guard let style = value as? BasicTableViewValueCell.Style else { return }
    switch style {
    case .forks(let item):
      self.viewModel.inputs.click(forks: item)
    case .releases(let item):
      self.viewModel.inputs.click(releases: item)
    case .activities(let item):
      self.viewModel.inputs.click(activities: item)
    case .contributors(let item):
      self.viewModel.inputs.click(contributors: item)
    case .stargazers(let item):
      self.viewModel.inputs.click(stargazers: item)
    case .pullRequests(let item):
      self.viewModel.inputs.click(pullRequests: item)
    case .issues(let item):
      self.viewModel.inputs.click(issues: item)
    case .readme(let readme):
      self.viewModel.inputs.click(readme: readme)
    case .commit(let item):
      self.viewModel.inputs.clickCommits(on: item)
    case .branch(let item):
      self.viewModel.inputs.click(branch: item)
    default:
      break
    }
  }
}



























