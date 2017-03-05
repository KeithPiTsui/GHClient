//
//  UserProfileViewController.swift
//  GHClient
//
//  Created by Pi on 02/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

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
    
    internal static func instantiate() -> UserProfileViewController {
        return Storyboard.UserProfile.instantiate(UserProfileViewController.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.events.dataSource = self.eventDatasource
        self.organizations.dataSource = self.organizationDatasource
        
        self.viewModel.inputs.viewDidLoad()
    }
    
    override func bindStyles() {
        super.bindStyles()
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
            self?.events.reloadData()
        }
        self.viewModel.outputs.organizations.observeForUI().observeValues { [weak self] in
            if $0.isEmpty {
                self?.organizationDatasource.noOrganization(msg: "No Organization")
            } else {
                self?.organizationDatasource.load(organizations: $0)
            }
            self?.organizations.reloadData()
        }
    }
}
























