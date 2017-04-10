//
//  ChangedFilesTableViewController.swift
//  GHClient
//
//  Created by Pi on 10/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveExtensions
import ReactiveSwift
import ReactiveCocoa
import Result

internal final class ChangedFilesTableViewController: UITableViewController {

  internal static func instantiate() -> ChangedFilesTableViewController {
    return Storyboard.ChangedFiles.instantiate(ChangedFilesTableViewController.self)
  }

  fileprivate let viewModel: ChangedFilesViewModelType = ChangedFilesViewModel()
  fileprivate let datasource = ChangedFilesDatasource()

  internal func set(files: [Commit.CFile]) {
    self.viewModel.inputs.set(files: files)
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
    self.viewModel.outpus.files.observeForUI().observeValues { [weak self] in
      self?.datasource.set(files: $0)
      self?.tableView.reloadData()
    }
  }
}

extension ChangedFilesTableViewController {
  internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let file = self.datasource[indexPath] as? Commit.CFile, let patch = file.patch else { return }
    let vc = HighlighterViewController.instantiate()
    vc.language = "diff"
    vc.code = patch
    self.navigationController?.pushViewController(vc, animated: true)
  }
}



















