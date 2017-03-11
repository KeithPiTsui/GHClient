//
//  RepositoryDatasource.swift
//  GHClient
//
//  Created by Pi on 11/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

fileprivate enum Section: Int {
    case Brief
    case DetailDiveIn
    case Branchs
    case Commits
    internal var name: String {
        return String(describing: self)
    }
}
extension Section: HashableEnumCaseIterating {}

internal final class RepositoryDatasource: ValueCellDataSource {

    fileprivate let titleSections: [Int] = [Section.Branchs.rawValue, Section.Commits.rawValue]


}


extension RepositoryDatasource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.titleSections.contains(section) {
            return Section(rawValue: section)?.name
        }
        return nil
    }
}
