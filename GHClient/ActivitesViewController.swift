//
//  ActivitesViewController.swift
//  GHClient
//
//  Created by Pi on 08/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

internal final class ActivitesViewController: UIViewController {

    internal static func instantiate() -> ActivitesViewController {
        return Storyboard.Activities.instantiate(ActivitesViewController.self)
    }
    
    fileprivate let viewModel: ActivitesViewModelType = ActivitesViewModel()
    fileprivate let watchingDatasource = ActivitesWatchingDatasource()
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
        self.tableView.dataSource = self.watchingDatasource
        self.viewModel.inputs.viewDidLoad()
    }

    override func bindStyles() {
        super.bindStyles()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        self.viewModel.outputs.events.observeForUI().observeValues { [weak self] in
            self?.watchingDatasource.load(watchings: $0)
            self?.tableView.reloadData()
        }
    }
}

























