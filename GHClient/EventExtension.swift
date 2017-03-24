//
//  PushEventExtension.swift
//  GHClient
//
//  Created by Pi on 22/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import GHAPI


internal typealias URLAttachedEventDescription = (desc: String, attachedURLs: [String: URL])

extension GHEvent {
  internal var eventDescription: URLAttachedEventDescription { return GHEventDescriber.describe(event: self) }
}


// MARK: -
// MARK: Event Description for AttributedLabel
internal enum GHEventDescriber {
  internal static func describe(event: GHEvent) -> URLAttachedEventDescription {
    var desc = ""
    var urls: [String: URL] = [:]
    let baseURL = AppEnvironment.current.apiService.serverConfig.apiBaseUrl

    switch event.type {
    case .PushEvent:
      let actorName = event.actor.login
      urls[actorName] = baseURL.appendingPathComponent("user")
      guard let repoName = event.repo?.name else  { break }
      urls[repoName] = baseURL.appendingPathComponent("repo")
      guard
        let pushEventPayload = event.payload as? PushEventPayload,
        let branchName = pushEventPayload.ref.components(separatedBy: "/").last
        else { break }
      urls[branchName] = baseURL.appendingPathComponent("branch")
      desc = "\(actorName) pushed to \(branchName) at \(repoName)"

    case .IssueCommentEvent:
      let actorName = event.actor.login
      urls[actorName] = baseURL.appendingPathComponent("user")
      guard let repo = event.repo?.name else { break }
      guard let issue = (event.payload as? IssueCommentEventPayload)?.issue.number else { break }
      let issueFullName = "\(repo)#\(issue)"
      urls[issueFullName] = baseURL.appendingPathComponent("issue_comment")
      desc = "\(actorName) commented on issue \(issueFullName)"

    default:
      break
    }

    return (desc, urls)
  }
}

// MARK: -
// MARK: ViewController for display content of part of event
extension GHEventDescriber {
  internal static func viewController(for event: GHEvent, with link: URL) -> UIViewController? {
    let components = link.pathComponents
    if components.contains("user") {
      let userUrl = event.userUrl
      let vc = UserProfileViewController.instantiate()
      vc.set(userUrl: userUrl)
      return vc
    } else if components.contains("repo") {
      guard let repoUrl = event.repoUrl else { return nil }
      let vc = RepositoryViewController.instantiate()
      vc.set(repoURL: repoUrl)
      return vc
    } else if components.contains("branch") {
      guard let branchUrl = event.branchUrl else { return nil }
      let vc = RepositoryContentTableViewController.instantiate()
      vc.set(contentURL: branchUrl)
      return vc
    } else if components.contains("issue") {
      guard let issueUrl = event.issueURL else { return nil }
      let vc = IssueTableViewController.instantiate()
      vc.set(issue: issueUrl)
      return vc

    } else if components.contains("commit") {

    } else if components.contains("issue_comment"){
      guard let issueUrl = event.issueURL else { return nil }
      let vc = IssueTableViewController.instantiate()
      vc.set(issue: issueUrl)
      return vc
    }

    return nil
  }
}


// MARK: -
// MARK: URL for part of event
extension GHEvent {
  internal var userUrl: URL { return self.actor.url }

  internal var repoUrl: URL? { return self.repo?.url }

  internal var branchUrl: URL? {
    guard let repoURL = self.repo?.url else { return nil }
    guard let branch = (self.payload as? PushEventPayload)?.ref.components(separatedBy: "/").last
      else { return nil }
    guard let repo = AppEnvironment.current.apiService.repository(referredBy: repoURL).single()?.value
      else { return nil}
    let url = AppEnvironment.current.apiService.contentURL(of: repo, ref: branch)
    return url
  }

  internal var issueURL: URL? {
    return (self.payload as? IssueCommentEventPayload)?.issue.urls.url
      ?? (self.payload as? IssueEventPayload)?.issue.urls.url
  }
}











