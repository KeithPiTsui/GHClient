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

  internal func setBrief(a: String, b: String, c: String, d: String) {
    self.appendRow(value: (a,b), cellClass: IndentedAlignedLabelTableViewCell.self, toSection: Section.Brief.rawValue)
    self.appendRow(value: c, cellClass: LabelOnlyTableViewCell.self, toSection: Section.Brief.rawValue)
    self.appendRow(value: (nil,d), cellClass: RegularBaseTableViewCell.self, toSection: Section.Brief.rawValue)
  }

  internal func setDetailDiveIn(values: [(UIImage?, String)]) {
    values.forEach {
      self.appendRow(value: $0, cellClass: RegularBaseTableViewCell.self, toSection: Section.DetailDiveIn.rawValue)
    }
  }

  internal func set(branches: [Branch]) {
    branches.forEach { (branch) in
      let value: (UIImage?, String) = (nil, branch.name)
      self.appendRow(value: value,
                     cellClass: RegularBaseTableViewCell.self,
                     toSection: Section.Branchs.rawValue)
    }
  }

  internal func setCommit(on branches: [Branch]) {
    branches.forEach { (branch) in
      let value: (UIImage?, String) = (nil, branch.name)
      self.appendRow(value: value,
                     cellClass: RegularBaseTableViewCell.self,
                     toSection: Section.Commits.rawValue)
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {
    switch (cell, value) {
    case let (cell as IndentedAlignedLabelTableViewCell, item as (String, String)):
      cell.configureWith(value: item)
    case let (cell as LabelOnlyTableViewCell, item as String):
      cell.configureWith(value: item)
    case let (cell as RegularBaseTableViewCell, item as (UIImage?, String)):
      cell.configureWith(value: item)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }

}

extension RepositoryDatasource {
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if self.titleSections.contains(section) {
      return Section(rawValue: section)?.name
    }
    return nil
  }
}
