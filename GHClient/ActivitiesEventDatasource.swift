//
//  ActivitiesEventDatasource.swift
//  GHClient
//
//  Created by Pi on 13/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class ActivitesEventDatasource: ValueCellDataSource {
  internal func load(events: [GHEvent]) {
    self.set(values: events, cellClass: EventTableViewCell.self, inSection: 0)
  }

  internal func load(receivedEvents: [GHEvent]) {
    self.set(values: receivedEvents, cellClass: EventTableViewCell.self, inSection: 0)
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
