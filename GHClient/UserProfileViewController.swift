//
//  UserProfileViewController.swift
//  GHClient
//
//  Created by Pi on 02/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import Prelude_UIKit
import Prelude
import ReactiveCocoa
import ReactiveSwift
import Result

final class UserProfileViewController: UIViewController {

    
    fileprivate let viewModel: UserProfileViewModelType = UserProfileViewModel()
    fileprivate let eventDatasource = UserProfileEventDatasource()
    fileprivate let organizationDatasource = UserProfileOrganizationDatasource()
    
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var repositories: UILabel!
    @IBOutlet weak var followings: UILabel!
    @IBOutlet weak var events: UITableView!
    @IBOutlet weak var organizations: UITableView!
    
    @IBOutlet weak var eventTableHeight: NSLayoutConstraint!
    @IBOutlet weak var organizationTableHeight: NSLayoutConstraint!
    
    
    @IBAction func tappedRefleshBtn(_ sender: UIBarButtonItem) {
        self.viewModel.inputs.tappedRefleshButton()
    }
    
    internal static func instantiate() -> UserProfileViewController {
        return Storyboard.UserProfile.instantiate(UserProfileViewController.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.events.dataSource = self.eventDatasource
        self.organizations.dataSource = self.organizationDatasource
        self.viewModel.inputs.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.inputs.viewWillAppear(animated: animated)
    }
    
    override func bindStyles() {
        super.bindStyles()
        _ = self.events |> UITableView.lens.rowHeight %~ {_ in return 46 }
        _ = self.organizations |> UITableView.lens.rowHeight %~ {_ in return 46 }
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        self.viewModel.outputs.followers.observeForUI().observeValues{ [weak self] in
            self?.followers.text = "\($0)"
        }
        self.viewModel.outputs.followings.observeForUI().observeValues{ [weak self] in
            self?.followings.text = "\($0)"
        }
        self.viewModel.outputs.repositories.observeForUI().observeValues{ [weak self] in
            self?.repositories.text = "\($0)"
        }
        self.viewModel.outputs.events.observeForUI().observeValues { [weak self] in
            self?.eventDatasource.load(events: $0)
            if let height = self?.events.rowHeight {
                self?.eventTableHeight.constant = height * CGFloat($0.count) - 2
            }
            self?.events.reloadData()
        }
        self.viewModel.outputs.organizations.observeForUI().observeValues { [weak self] in
            if $0.isEmpty {
                self?.organizationDatasource.noOrganization(msg: "No Organization")
            } else {
                self?.organizationDatasource.load(organizations: $0)
            }
            if let height = self?.organizations.rowHeight,
                let orgY = self?.organizations.frame.origin.y,
                let blg = self?.bottomLayoutGuide.length,
                let viewHeight = self?.view.frame.height,
                viewHeight > 0 {
                
                let rowCount = $0.isEmpty ? 1 : $0.count
                let expectedHeight = height * CGFloat(rowCount)
                let maxHeight = viewHeight - blg - orgY

                self?.organizations.isScrollEnabled = expectedHeight > maxHeight
                self?.organizationTableHeight.constant = min(expectedHeight, maxHeight) - 2
            }
            self?.organizations.reloadData()
        }
    }
    
    
}























