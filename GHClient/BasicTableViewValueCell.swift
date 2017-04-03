//
//  BasicTableViewValueCell.swift
//  GHClient
//
//  Created by Pi on 03/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI
import ReactiveCocoa
import Prelude_UIKit
import Ladder

internal final class BasicTableViewValueCell: UITableViewCell, ValueCell {

  internal enum Style {
    case forks([Repository]?)
    case fork(Repository)
    case releases([Release]?)
    case release(Release)
    case activities([GHEvent]?)
    case activity(GHEvent)
    case contributors([UserLite]?)
    case contributor(UserLite)
    case stargazers([UserLite]?)
    case stargazer(UserLite)
    case pullRequests([PullRequest]?)
    case pullRequest(PullRequest)
    case issues([Issue]?)
    case issue(Issue)
    case readme(Readme?)
    case repoDescription(String)
    case commit(BranchLite)
    case branch(BranchLite)
    case repositoryContent(Content)
  }

  override func awakeFromNib() {
    self.textLabel?.numberOfLines = 0
  }

  func configureWith(value: BasicTableViewValueCell.Style) {
    self.imageView?.image = nil
    self.textLabel?.text = ""
    self.accessoryType = .disclosureIndicator

    switch value {
    case .forks(_):
      self.imageView?.image = UIImage(named: "repo-forked")!
      self.textLabel?.text = "forks"
    case .releases(_):
      self.imageView?.image = UIImage(named: "tag")!
      self.textLabel?.text = "releases"
    case .activities(_):
      self.imageView?.image = UIImage(named: "rss")!
      self.textLabel?.text = "activities"
    case .contributors(_):
      self.imageView?.image = UIImage(named: "organization")!
      self.textLabel?.text = "contributors"
    case .stargazers(_):
      self.imageView?.image = UIImage(named: "star")!
      self.textLabel?.text = "stargazers"
    case .pullRequests(_):
      self.imageView?.image = UIImage(named: "git-pull-request")!
      self.textLabel?.text = "pull requests"
    case .issues(_):
      self.imageView?.image = UIImage(named: "info")!
      self.textLabel?.text = "issues"
    case .readme(let readme):
      self.textLabel?.text = readme == nil ? "No Readme" : "Readme"
      self.accessoryType = .none
    case .repoDescription(let desc):
      self.textLabel?.text = desc
      self.accessoryType = .none
    case .commit(let branch):
      self.textLabel?.text = branch.name
    case .branch(let branch):
      self.textLabel?.text = branch.name
    case .repositoryContent(let content):
      var iconName = "file"
      if content.type == "file" {
        iconName = "file"
        self.accessoryType = .detailDisclosureButton
      } else if content.type == "dir" {
        iconName = "file-directory"
        self.accessoryType = .disclosureIndicator
      }
      self.imageView?.image = UIImage(named: iconName)!
      self.textLabel?.text = content.name
    case .fork(let repo):
      self.textLabel?.text = repo.name
    case .release(let rel):
      self.textLabel?.text = rel.tag_name
    case .activity(let event):
      self.textLabel?.text = event.actor.login
    case .contributor(let user):
      self.textLabel?.text = user.login
    case .stargazer(let user):
      self.textLabel?.text = user.login
    case .pullRequest(let pr):
      self.textLabel?.text = pr.body
    case .issue(let isu):
      self.textLabel?.text = isu.body
    }
  }
}
