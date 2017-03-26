//
//  TrendingRepositoryTableViewCell.swift
//  GHClient
//
//  Created by Pi on 14/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

internal final class TrendingRepositoryTableViewCell: UITableViewCell, ValueCell {

  @IBOutlet weak var repoFullName: UILabel!
  @IBOutlet weak var repoDesc: UILabel!
  @IBOutlet weak var language: UILabel!
  @IBOutlet weak var stars: UILabel!
  @IBOutlet weak var forks: UILabel!
  @IBOutlet weak var periodStars: UILabel!
  @IBOutlet weak var langIcon: UIImageView!
  @IBOutlet weak var forkIcon: UIImageView!
  @IBOutlet weak var starIcon: UIImageView!
  @IBOutlet weak var periodStarIcon: UIImageView!

  internal var periodDesc: String = "today"

  override func awakeFromNib() {
    super.awakeFromNib()
    self.langIcon.tintColor = UIColor.orange
    self.starIcon.tintColor = UIColor.yellow
    self.forkIcon.tintColor = UIColor.darkGray
    self.periodStarIcon.tintColor = UIColor.yellow
  }

  func configureWith(value: TrendingRepository) {
    self.repoFullName.text = "\(value.repoOwner ?? "")\\\(value.repoName ?? "")"
    self.repoDesc.text = value.repoDesc ?? ""
    self.language.text = value.programmingLanguage ?? ""
    self.stars.text = "\(value.totoalStars ?? 0)"
    self.forks.text = "\(value.forks ?? 0)"
    self.periodStars.text = "\(value.periodStars ?? 0) stars " + self.periodDesc
  }
}
