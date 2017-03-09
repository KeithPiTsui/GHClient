//
//  SearchViewController.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import Prelude
import Prelude_UIKit
import GHAPI

internal final class SearchViewController: UIViewController {

    internal static func instantiate() -> SearchViewController { return Storyboard.Search.instantiate(SearchViewController.self)}
    fileprivate let userDatasource = SearchUserDataSource()
    fileprivate let repositoryDatasource = SearchRepositoryDataSource()
    fileprivate let viewModel: SearchViewModelType = SearchViewModel()
    
    @IBOutlet weak var searchScopeSelector: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dimView: UIView!
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        self.viewModel.inputs.scopeSegmentChanged(index: sender.selectedSegmentIndex)
    }
    
    @IBAction func tappedSearchFilterBtn(_ sender: UIBarButtonItem) {
        self.viewModel.inputs.tappedFilterButton(within: self.scope)
    }
    
    @IBAction func tapOnDimView(_ sender: UITapGestureRecognizer) {
        self.viewModel.inputs.tappedOnDimView()
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
        _ = self.dimView |> UIView.lens.hidden .~ true
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel.outputs.searchScopes.observeForUI().observeValues { [weak self] in
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
            self?.reveal(filter: $0)
        }
        
        self.viewModel.outputs.removeFilter.observeForUI().observeValues { [weak self] (filter) in
            UIView.animate(withDuration: 0.3, animations: {
                self?.dimView.isHidden = true
                filter.view.frame.origin.x = self?.tableView.frame.size.width ?? 0
            }) { _ in
                filter.willMove(toParentViewController: nil)
                filter.view.removeFromSuperview()
                filter.removeFromParentViewController()
            }
        }
    }
    
    fileprivate func reveal(filter: SearchFilterViewController) {
        guard let v = filter.view else { return }
        
        self.addChildViewController(filter)
        
        var filterFrame = self.tableView.frame
        filterFrame.origin.x = filterFrame.size.width
        filterFrame.size.width *= 0.8
        v.frame = filterFrame
        v.layer.shadowRadius = 6
        v.layer.shadowOpacity = 1
        v.layer.shadowOffset = CGSize(width: 5, height: 5)
        
        self.view.addSubview(v)
        filter.didMove(toParentViewController: self)
        
        var newFilterFrame = filterFrame
        newFilterFrame.origin.x = self.tableView.frame.width - v.frame.width
        
        UIView.animate(withDuration: 0.3) {
            self.dimView.isHidden = false
            v.frame = newFilterFrame
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    internal func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let keyword = self.searchBar.text else { return }
        self.viewModel.inputs.search(scope: self.scope, keyword: keyword, qualifiers: [])
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






























