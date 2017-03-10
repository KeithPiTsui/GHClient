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
    
    func edgePan(_ sender: UIScreenEdgePanGestureRecognizer) {
        self.viewModel.inputs.screenEdgePan()
    }
    
    fileprivate var scope: SearchScope {
        let scope: SearchScope
        switch self.searchScopeSelector.selectedSegmentIndex {
        case 0:
            scope = SearchScope.userUnit
        case 1:
            scope = SearchScope.repositoryUnit
        case 2:
            scope = SearchScope.codeUnit
        default:
            scope = SearchScope.userUnit
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
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgePan(_:)))
        edgePan.edges = .right
        self.view.addGestureRecognizer(edgePan)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.searchBar.reactive.continuousTextValues
            .map{ ($0 ?? "").isEmpty }
            .filter{$0}
            .observeForUI()
            .observeValues { [weak self] _ in
                self?.userDatasource.clearValues()
                self?.repositoryDatasource.clearValues()
                self?.tableView.reloadData()
        }
        
        
        self.viewModel.outputs.searchScopes.observeForUI()
            .observeValues { [weak self] in
            self?.searchScopeSelector.removeAllSegments()
            for (idx, scope) in $0.enumerated() {
                self?.searchScopeSelector.insertSegment(withTitle: scope.name, at: idx, animated: false)
            }
        }
        
        self.viewModel.outputs.selectedSearchScope.observeForUI()
            .observeValues { [weak self] in
            switch $0 {
            case .users:
                self?.searchScopeSelector.selectedSegmentIndex = 0
                self?.userDatasource.clearValues()
                self?.tableView.dataSource = self?.userDatasource
                self?.tableView.reloadData()
                self?.searchBar.becomeFirstResponder()
            case .repositories:
                self?.searchScopeSelector.selectedSegmentIndex = 1
                self?.repositoryDatasource.clearValues()
                self?.tableView.dataSource = self?.repositoryDatasource
                self?.tableView.reloadData()
                self?.searchBar.becomeFirstResponder()
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

        self.viewModel.outputs.presentFilter.observeForUI().observeValues { [weak self] (filter) in
            guard let v = filter.view else { return }
            guard let scope = self?.scope else { return }
            self?.searchBar.resignFirstResponder()
            filter.delegate = self
            filter.setFilterScope(scope)
            self?.addChildViewController(filter)
            
            var filterFrame = self?.tableView.frame ?? CGRect.zero
            filterFrame.origin.x = filterFrame.size.width
            filterFrame.size.width *= 0.8
            filterFrame.origin.y += (filterFrame.size.height * 0.05)
            filterFrame.size.height *= 0.9
            
            v.frame = filterFrame
            v.clipsToBounds = true
            v.layer.cornerRadius = 6
            v.layer.shadowRadius = 6
            v.layer.shadowOpacity = 1
            v.layer.shadowOffset = CGSize(width: 5, height: 5)
            
            self?.view.addSubview(v)
            filter.didMove(toParentViewController: self)
            
            var newFilterFrame = filterFrame
            newFilterFrame.origin.x = (self?.tableView.frame.width ?? 0) - v.frame.width
            
            UIView.animate(withDuration: 0.5) {
                self?.dimView.isHidden = false
                v.frame = newFilterFrame
            }
        }
        
        self.viewModel.outputs.removeFilter.observeForUI().observeValues { [weak self] (filter) in
            UIView.animate(withDuration: 0.5, animations: {
                self?.dimView.isHidden = true
                filter.view.frame.origin.x = self?.tableView.frame.size.width ?? 0
            }) { _ in
                filter.willMove(toParentViewController: nil)
                filter.view.removeFromSuperview()
                filter.removeFromParentViewController()
            }
        }
        
        self.viewModel.outputs.searchBarPlaceholder.observeForUI().observeValues { [weak self] in
            self?.searchBar.placeholder = $0
        }
    }
    
    fileprivate var filterStartPoint: CGPoint = CGPoint.zero
    fileprivate var previousPoint: CGPoint = CGPoint.zero
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
    
    func closeFilter() {
        
    }
    
    func wipe(filter: SearchFilterViewController, beginAt point: CGPoint) {
        self.filterStartPoint = point
        previousPoint = point
    }
    
    func wipe(filter: SearchFilterViewController, rightForwardAt point: CGPoint) {
        
        let dx = point.x - previousPoint.x
        previousPoint = point
        
        filter.view.frame.origin.x += dx
    }
    
    func wipe(filter: SearchFilterViewController, endAt point: CGPoint) {
        
        
        self.filterStartPoint = CGPoint.zero
    }
}






























