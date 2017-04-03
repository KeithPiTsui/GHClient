//
//  CommitDatasource.swift
//  GHClient
//
//  Created by Pi on 30/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class CommitDatasource: ValueCellDataSource {

  internal enum CommitChangesType {
    case additions
    case deletions
    case modifications
    case allFiles
    case allDiffs
  }

  internal enum Section: Int {
    case commitDescription
    case changes
    case comments
  }

  internal func set(commit: Commit) {
    self.set(values: [commit],
             cellClass: CommitDescriptionTableViewCell.self,
             inSection: Section.commitDescription.rawValue)
  }

  internal func set(commitComments: [CommitComment]) {
    self.set(values: commitComments,
             cellClass: CommitCommentTableViewCell.self,
             inSection: Section.comments.rawValue)
  }

  fileprivate func valueConstructor(for changesType: CommitChangesType)
    -> ([Commit.CFile]) -> BasicTableViewValueCell.Style {
      let vc: ([Commit.CFile]) -> BasicTableViewValueCell.Style
      switch changesType {
      case .additions:
        vc = BasicTableViewValueCell.Style.commitChangeAddition
      case .deletions:
        vc = BasicTableViewValueCell.Style.commitChangeDeletion
      case .modifications:
        vc = BasicTableViewValueCell.Style.commitChangeModification
      case .allDiffs:
        vc = BasicTableViewValueCell.Style.commitChangeAllDiff
      case .allFiles:
        vc = BasicTableViewValueCell.Style.commitChangeAllFile
      }
      return vc
  }

  fileprivate func valueConstructor(of files: [Commit.CFile]) -> (CommitChangesType) -> BasicTableViewValueCell.Style {
    return { self.valueConstructor(for: $0)(files) }
  }

  internal func setCommitChanges(files: [Commit.CFile],
                                 with changesTypes: [CommitChangesType]) {
    let values = changesTypes.map(self.valueConstructor(of: files))
    self.set(values: values, cellClass: BasicTableViewValueCell.self, inSection: Section.changes.rawValue)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any, for indexPath: IndexPath) {
    switch (cell, value) {
    case let (cell as BasicTableViewValueCell, item as BasicTableViewValueCell.Style):
      cell.configureWith(value: item)
    case let (cell as CommitDescriptionTableViewCell, item as Commit):
      cell.configureWith(value: item)
    case let (cell as CommitCommentTableViewCell, item as CommitComment):
      cell.configureWith(value: item)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
extension CommitDatasource.CommitChangesType: HashableEnumCaseIterating {}
