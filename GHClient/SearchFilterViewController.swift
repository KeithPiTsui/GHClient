//
//  SearchFilterViewController.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class SearchFilterViewController: UIViewController {

    internal static func instantiate() -> SearchFilterViewController {
        return Storyboard.SearchFilter.instantiate(SearchFilterViewController.self)
    }
    
    fileprivate let viewModel = SearchFilterViewModel()
    fileprivate let repositoriesDatasource = SearchFilterRepositoriesDatasource()
    fileprivate let usersDatasource = SearchFilterUsersDatasource()

    @IBOutlet weak var filterOptionsCollectionView: UICollectionView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func tappedResetBtn(_ sender: UIButton) {
        
    }
    
    @IBAction func tappedOkayBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    internal func setFilterScope(_ scope: SearchScope) {
        self.title = scope.name.uppercased() + " Search Filter"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.filterOptionsCollectionView.dataSource = self.usersDatasource
        self.filterOptionsCollectionView.allowsMultipleSelection = true
        self.filterOptionsCollectionView.allowsSelection = true
    }
    
    override func bindStyles() {
        super.bindStyles()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
    }
}

extension SearchFilterViewController: UICollectionViewDelegate {
    
}


































