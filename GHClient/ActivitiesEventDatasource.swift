//
//  ActivitiesEventDatasource.swift
//  GHClient
//
//  Created by Pi on 13/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class EventDatasource: ValueCellDataSource {

  internal func load(events: [GHEvent]) {
    self.set(values: events,
             cellClass: EventTableViewCell.self,
             inSection: 0)
  }

  fileprivate func set(event: GHEvent, and image: UIImage, at indexPath: IndexPath) {
    self.set(value: event,
             cellClass: EventTableViewCell.self,
             inSection: indexPath.section,
             row: indexPath.row)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {
    switch (cell, value) {
    case let (cell as EventTableViewCell, item as GHEvent):
      cell.configureWith(value: item)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
