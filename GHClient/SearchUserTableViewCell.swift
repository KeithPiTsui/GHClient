//
//  SearchUserTableViewCell.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class SearchUserTableViewCell: UITableViewCell, ValueCell {
    internal func configureWith(value: User) {
        self.textLabel?.text = value.login
    }
}
