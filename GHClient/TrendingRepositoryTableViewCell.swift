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

  internal var section: Int = 0
  internal var row: Int = 0
  internal weak var dataSource: ValueCellDataSource?
  internal var periodDesc: String = ""

  func configureWith(value: TrendingRepository) {
    self.repoFullName.text = "\(value.repoOwner ?? "")\\\(value.repoName ?? "")"
    self.repoDesc.text = value.repoDesc ?? ""
    self.language.text = value.programmingLanguage ?? ""
    self.stars.text = "\(value.totoalStars ?? 0)"
    self.forks.text = "\(value.forks ?? 0)"
    self.periodStars.text = "\(value.periodStars ?? 0) " + self.periodDesc
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
