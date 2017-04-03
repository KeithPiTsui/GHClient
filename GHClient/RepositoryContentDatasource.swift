//
//  RepositoryContentDatasource.swift
//  GHClient
//
//  Created by Pi on 21/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class RepositoryContentDatasource: ValueCellDataSource {

  internal func content(of indexPath: IndexPath) -> Content? {
    if let value = self[indexPath] as? BasicTableViewValueCell.Style,
      case let .repositoryContent(content) = value {
      return content
    }
    return nil
  }

  internal func load(contents: [Content]) {
    self.set(values: contents.map(BasicTableViewValueCell.Style.repositoryContent),
             cellClass: BasicTableViewValueCell.self,
             inSection: 0)

  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {
    switch (cell, value) {
    case let (cell as BasicTableViewValueCell, item as BasicTableViewValueCell.Style):
      cell.configureWith(value: item)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
