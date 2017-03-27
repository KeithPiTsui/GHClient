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
    switch value {
    case let item as UserLite: /// Click on owner
      self.viewModel.inputs.click(repoOwner: item)
    case let value where (unwrap(value: value) as (Readme?, Bool)).1: // Click readme
      let item = (unwrap(value: value) as (Readme?, Bool)).0
      self.viewModel.inputs.click(readme: item)
    case let value where (unwrap(value: value) as ([Repository]?, Bool)).1: // click forks
      let item = (unwrap(value: value) as ([Repository]?, Bool)).0
      self.viewModel.inputs.click(forks: item)
    case let value where (unwrap(value: value) as ([Release]?, Bool)).1: // click releases
      let item = (unwrap(value: value) as ([Release]?, Bool)).0
      self.viewModel.inputs.click(releases: item)
    case let value where (unwrap(value: value) as ([GHEvent]?, Bool)).1: // click activities
      let item = (unwrap(value: value) as ([GHEvent]?, Bool)).0
      self.viewModel.inputs.click(activities: item)
    case let value where (unwrap(value: value) as ([UserLite]?, Bool)).1: // click contributors or stargazers
      let item = (unwrap(value: value) as ([UserLite]?, Bool)).0
      if indexPath.section == RepositoryDatasource.Section.DetailDiveIn.rawValue
        && indexPath.row == RepositoryDatasource.Section.RepoPorperty.contributors.rawValue {
        self.viewModel.inputs.click(contributors: item)
      } else if indexPath.section == RepositoryDatasource.Section.DetailDiveIn.rawValue
        && indexPath.row == RepositoryDatasource.Section.RepoPorperty.stargazers.rawValue{
        self.viewModel.inputs.click(stargazers: item)
      }
    case let value where (unwrap(value: value) as ([PullRequest]?, Bool)).1: // click pull requests
      let item = (unwrap(value: value) as ([PullRequest]?, Bool)).0
      self.viewModel.inputs.click(pullRequests: item)
    case let value where (unwrap(value: value) as ([Issue]?, Bool)).1: // click issue
      let item = (unwrap(value: value) as ([Issue]?, Bool)).0
      self.viewModel.inputs.click(issues: item)
    case let item as BranchLite: // click branches or commits
      if indexPath.section == RepositoryDatasource.Section.Branchs.rawValue {
        self.viewModel.inputs.click(branch: item)
      } else if indexPath.section == RepositoryDatasource.Section.Commits.rawValue {
        self.viewModel.inputs.clickCommits(on: item)
      }
    default:
      break
    }
  }
}



























