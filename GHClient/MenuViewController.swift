//
//  MenuViewController.swift
//  GHClient
//
//  Created by Pi on 02/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

final class MenuViewController: UITableViewController {

  internal static func instantiate() -> MenuViewController { return Storyboard.Menu.instantiate(MenuViewController.self)}

  fileprivate var rootSplitViewController: RootSplitViewController? {
    return self.splitViewController as? RootSplitViewController
  }

  fileprivate let viewModel: MenuViewModelType = MenuViewModel()
  fileprivate let datasource = MenuDataSource()

  @IBOutlet weak var username: UIBarButtonItem!

  @IBAction func tappedOnUserIcon(_ sender: UIBarButtonItem) {
    self.viewModel.inputs.tappedUserIcon()
  }

  internal required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    NotificationCenter.default
      .addObserver(forName: Notification.Name.gh_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    NotificationCenter.default
      .addObserver(forName: Notification.Name.gh_sessionEnded, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionEnded()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = self.datasource
    self.viewModel.inputs.viewDidLoad()
  }

  override func bindStyles() {
    super.bindStyles()
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outpus.username.observeForUI().observeValues { [weak self] in
      self?.username.title = $0
    }

    self.viewModel.outpus.presentViewController.observeForUI().observeValues{ [weak self] in
      self?.dismiss(animated: true, completion: nil)
      self?.present($0, animated: true, completion: nil)
    }

    self.viewModel.outpus.personalMenuItems.observeForUI().observeValues{ [weak self] in
      self?.datasource.load(personalItems: $0)
      self?.tableView.reloadData()
    }

    self.viewModel.outpus.discoveryMenuItems.observeForUI().observeValues{ [weak self] in
      self?.datasource.load(discoveryItems: $0)
      self?.tableView.reloadData()
    }

    self.viewModel.outpus.appMenuItems.observeForUI().observeValues{ [weak self] in
      self?.datasource.load(appItems: $0)
      self?.tableView.reloadData()
    }

    self.viewModel.outpus.gotoUserProfile.observeForUI().observeValues{ [weak self] _ in
      self?.rootSplitViewController?.gotoUserProfile()
    }

    self.viewModel.outpus.gotoSearching.observeForUI().observeValues { [weak self] in
      self?.rootSplitViewController?.gotoSearch()
    }

  }


  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let menuItem = self.datasource[indexPath] as? MenuItem else { return }
    self.viewModel.inputs.tappedMenuItem(menuItem)
  }




}
