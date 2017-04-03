//
//  CommitDescriptionTableViewCell.swift
//  GHClient
//
//  Created by Pi on 30/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveCocoa
import Prelude_UIKit
import Ladder

internal final class CommitDescriptionTableViewCell: UITableViewCell, ValueCell {

  @IBOutlet weak var commitDescriptionLabel: GHCAttributedLabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    self.commitDescriptionLabel.numberOfLines = 0
  }

  func configureWith(value: Commit) {
    let author = value.commit.author.name
    let authorURL = AppEnvironment.current.apiService.userURL(with: author)
    let repoOwner = value.url.pathComponents[2]
    let repo = value.url.pathComponents[3]
    let desc = "\(author) committed these changes for \(repoOwner)\\\(repo)"
    self.commitDescriptionLabel.setText(desc)
    let nsDesc = desc as NSString
    let authorRange = nsDesc.range(of: author)
    self.commitDescriptionLabel.addLink(to: authorURL, with: authorRange)
    let repoRange = nsDesc.range(of: "\(repoOwner)\\\(repo)")
    let repoULR = AppEnvironment.current.apiService.repositoryUrl(of: repoOwner, and: repo)
    self.commitDescriptionLabel.addLink(to: repoULR, with: repoRange)
  }
}
