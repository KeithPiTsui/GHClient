//
//  SearchFilterViewController.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class SearchFilterViewController: UITableViewController {

    internal static func instantiate() -> SearchFilterViewController {
        return Storyboard.SearchFilter.instantiate(SearchFilterViewController.self)
    }
    
    fileprivate let viewModel = SearchFilterViewModel()
    fileprivate let repositoriesDatasource = SearchFilterRepositoriesDatasource()
    fileprivate let usersDatasource = SearchFilterUsersDatasource()
    @IBAction func TappedCancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedDoneButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    internal func setFilterScope(_ scope: SearchScope) {
        self.title = scope.name + " Search Filter"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bindStyles() {
        super.bindStyles()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
    }
}
