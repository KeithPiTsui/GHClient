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
    @IBOutlet weak var filterViewHeight: NSLayoutConstraint!
    @IBOutlet weak var filterContainer: UIView!
    
    @IBOutlet weak var filterDescription: UILabel!
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
    
    internal func updateFilterDescription() {
        if self.scope == SearchScope.userUnit && self.userQualifiers.isEmpty == false {
            self.filterViewHeight.constant = 60
            self.filterDescription.text = self.userQualifiers.map{$0.searchRepresentation}.joined(separator: "+")
        } else if self.scope == SearchScope.repositoryUnit && self.repoQualifiers.isEmpty == false {
            self.filterViewHeight.constant = 60
            self.filterDescription.text = self.repoQualifiers.map{$0.searchRepresentation}.joined(separator: "+")
        } else {
            self.filterViewHeight.constant = 0
            self.filterDescription.text = nil
        }
        self.view.layoutIfNeeded()
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
            
            var filterFrame = self?.dimView.frame ?? CGRect.zero
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
            
            if self?.scope == SearchScope.userUnit, let uqs = self?.userQualifiers {
                filter.specify(qualifiers: uqs)
            } else if self?.scope == SearchScope.repositoryUnit, let rqs = self?.repoQualifiers {
                filter.specify(qualifiers: rqs )
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
    fileprivate var userQualifiers: [UserQualifier] = []
    fileprivate var repoQualifiers: [RepositoriesQualifier] = []
}

extension SearchViewController {
    fileprivate func search() {
        guard let keyword = self.searchBar.text else { return }
        self.search(keyword: keyword)
    }
    
    fileprivate func search(keyword: String) {
        var qualifiers: [SearchQualifier] = self.userQualifiers
        if self.scope == SearchScope.userUnit {
            qualifiers = self.userQualifiers
        } else if self.scope == SearchScope.repositoryUnit {
            qualifiers = self.repoQualifiers
        }
        self.viewModel.inputs.search(scope: self.scope, keyword: keyword, qualifiers: qualifiers)
    }
}



extension SearchViewController: UISearchBarDelegate {
    internal func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.search()
    }
    
    internal func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: SearchFilterViewControllerDelegate {
    
    func filteredQualifiers(_ qualifiers: [SearchQualifier]) {
        if let qs = qualifiers as? [UserQualifier] {
            self.userQualifiers = qs
        } else if let qs = qualifiers as? [RepositoriesQualifier] {
            self.repoQualifiers = qs
        }
        self.viewModel.inputs.tappedOnDimView()
        self.updateFilterDescription()
        self.search()
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

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.scope == SearchScope.userUnit {
            guard let user = self.userDatasource[indexPath] as? User,
            let url = URL(string: user.urls.url) else { return }
            let vc = UserProfileViewController.instantiate()
            vc.set(userUrl: url)
            self.navigationController?.pushViewController(vc, animated: true)
            self.tableView.deselectRow(at: indexPath, animated: false)
        } else if self.scope == SearchScope.repositoryUnit {
            let vc = RepositoryViewController.instantiate()
            self.navigationController?.pushViewController(vc, animated: true)
            self.tableView.deselectRow(at: indexPath, animated: false)
        }
    }
}





























