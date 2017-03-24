//
//  RepositoryContentTableViewController.swift
//  GHClient
//
//  Created by Pi on 21/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import ReactiveExtensions
import Result
import GHAPI

internal final class RepositoryContentTableViewController: UITableViewController {

  internal static func instantiate() -> RepositoryContentTableViewController {
    return Storyboard.RepositoryContent.instantiate(RepositoryContentTableViewController.self)
  }

  fileprivate let datasource = RepositoryContentDatasource()
  fileprivate let viewModel: RepositoryContentViewModelType = RepositoryContentViewModel()

  internal func set(repo: Repository, and branch: BranchLite) {
    self.viewModel.inputs.set(repo: repo, and: branch)
  }

  internal func set(contentURL: URL) {
    self.viewModel.inputs.set(contentURL: contentURL)
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
    self.viewModel.outpus.contents.observeForUI().observeValues { [weak self] (contents) in
      self?.datasource.load(contents: contents)
      self?.tableView.reloadData()
    }

    self.viewModel.outpus.presentAlert.observeForControllerAction().observeValues { [weak self] in
      self?.present($0, animated: true, completion: nil)
    }

    self.viewModel.outpus.presentSourceCodeViewer.observeForControllerAction().observeValues { [weak self] in
      self?.navigationController?.pushViewController($0, animated: true)
    }

    self.viewModel.outpus.presentDocumentController.observeForControllerAction().observeValues { [weak self] in
      $0.delegate = self
      $0.presentPreview(animated: true)
    }

    self.viewModel.outpus.presentMediaVC.observeForControllerAction().observeValues { [weak self] (playerVC) in
      self?.present(playerVC, animated: true) {
        playerVC.player?.play()
      }
    }

    self.viewModel.outpus.pushNextDirectory.observeForControllerAction().observeValues { [weak self] in
      self?.navigationController?.pushViewController($0, animated: true)
    }

    self.viewModel.outpus.presentMarkupViewer.observeForControllerAction().observeValues { [weak self] in
      self?.navigationController?.pushViewController($0, animated: true)
    }

  }
}

extension RepositoryContentTableViewController {
  internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let value = self.datasource[indexPath] as? Content else { return }
    self.viewModel.inputs.tapped(on: value)
  }
}

extension RepositoryContentTableViewController: UIDocumentInteractionControllerDelegate {
  func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController)
    -> UIViewController {
    return self
  }
}




















