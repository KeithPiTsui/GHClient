//
//  SearchViewController.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class SearchViewController: UITableViewController {

    internal static func instantiate() -> SearchViewController { return Storyboard.Search.instantiate(SearchViewController.self)}
    fileprivate let userDatasource = SearchUserDataSource()
    fileprivate let repositoryDatasource = SearchRepositoryDataSource()
    fileprivate let viewModel: SearchViewModelType = SearchViewModel()
    
    @IBOutlet weak var searchScopeSelector: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        self.viewModel.inputs.scopeSegmentChanged(index: sender.selectedSegmentIndex)
    }
    
    @IBAction func tappedSearchFilterBtn(_ sender: UIBarButtonItem) {
        self.viewModel.inputs.tappedFilterButton(within: self.scope)
    }
    
    fileprivate var scope: SearchScope {
        let scope: SearchScope
        switch self.searchScopeSelector.selectedSegmentIndex {
        case 0:
            scope = .users([])
        case 1:
            scope = .repositories([])
        case 2:
            scope = .code([])
        default:
            scope = .users([])
        }
        return scope
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.viewModel.inputs.viewDidLoad()
    }
    
    override func bindStyles() {
        super.bindStyles()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel.outputs.searchScope.observeForUI().observeValues { [weak self] in
            self?.searchScopeSelector.removeAllSegments()
            for (idx, scope) in $0.enumerated() {
                self?.searchScopeSelector.insertSegment(withTitle: scope.name, at: idx, animated: false)
            }
        }
        
        self.viewModel.outputs.selectedSearchScope.observeForUI().observeValues { [weak self] in
            switch $0 {
            case .users:
                self?.searchScopeSelector.selectedSegmentIndex = 0
                self?.tableView.dataSource = self?.userDatasource
            case .repositories:
                self?.searchScopeSelector.selectedSegmentIndex = 1
                self?.tableView.dataSource = self?.repositoryDatasource
            default:
                break
            }
        }
        
        self.viewModel.outputs.users.observeForUI().observeValues{ [weak self] in
            self?.userDatasource.load(users: $0)
            self?.tableView.reloadData()
        }
        
        self.viewModel.outputs.repositories.observeForUI().observeValues{ [weak self] in
            self?.repositoryDatasource.load(repositories: $0)
            self?.tableView.reloadData()
        }

        self.viewModel.outputs.presentSearchFilterViewController.observeForUI().observeValues { [weak self] in
            $0.delegate = self
            let nvc = UINavigationController(rootViewController: $0)
            self?.dismiss(animated: true, completion: nil)
            self?.present(nvc, animated: true, completion: nil)
        }
//        self.viewModel.outputs.presentViewController.observeForUI().observeValues { [weak self] in
//            self?.dismiss(animated: true, completion: nil)
//            self?.present($0, animated: true, completion: nil)
//        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    internal func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let keyword = self.searchBar.text else { return }
        self.viewModel.inputs.search(scope: self.scope, keyword: keyword)
    }
    
    internal func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: SearchFilterViewControllerDelegate {
    func filteredQualifiers(_ qualifiers: [SearchQualifier]) {
        self.viewModel.inputs.search(scope: self.scope, keyword: "Keith", qualifiers: qualifiers)
    }
}






























