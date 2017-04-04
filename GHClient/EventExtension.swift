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

fileprivate enum URLTargetStrings: String {
  case user
  case repository
  case branchContent
  case issue
  case pullRequest
}




// MARK: -
// MARK: Event Description for AttributedLabel
internal enum GHEventDescriber {
  internal static func describe(event: GHEvent) -> URLAttachedEventDescription {
    var desc = ""
    var urls: [String: URL] = [:]

    let actor = event.actor.login
    let actorURL = event.actor.url
    urls[actor] = actorURL.appendingPathComponent(URLTargetStrings.user.rawValue)

    let repoName = event.repo?.name
    let repoURL = event.repo?.url
    if let rn = repoName {
      urls[rn] = repoURL?.appendingPathComponent(URLTargetStrings.repository.rawValue)
    }


    switch event.type {
    case .PushEvent:
      guard
        let pushEventPayload = event.payload as? PushEventPayload,
        let branchName = pushEventPayload.ref.components(separatedBy: "/").last
        else { break }

      guard let repo = event.repo else { break }
      let contentURL = AppEnvironment.current.apiService.contentURL(of: repo.url, ref: branchName)
      urls[branchName] = contentURL.appendingPathComponent(URLTargetStrings.branchContent.rawValue)
      desc = "\(actor) pushed to \(branchName) at \(repoName ?? "")"

    case .IssueCommentEvent:
      guard let icePayload = event.payload as? IssueCommentEventPayload else { break }
      guard let repoName = event.repo?.name else { break }

      let action = icePayload.action
      let issue = icePayload.issue.pull_request == nil
        ? "issue"
        : "pull request"
      let issueURL = icePayload.issue.pull_request?.url ?? icePayload.issue.urls.url
      let issueName = "\(repoName)#\(icePayload.issue.number)"
      let targetString = icePayload.issue.pull_request == nil
        ? URLTargetStrings.issue.rawValue
        : URLTargetStrings.pullRequest.rawValue
      urls[issueName] = issueURL.appendingPathComponent(targetString)
      desc = "\(actor) \(action) comment on \(issue) \(issueName)"

    case .ForkEvent:
      let pushEventPayload = event.payload as? ForkEventPayload
      let forkeeName = pushEventPayload?.forkee.full_name
      if let fn = forkeeName {
        urls[fn] = pushEventPayload?.forkee.urls.url.appendingPathComponent(URLTargetStrings.repository.rawValue)
      }
      desc = "\(actor) forked \(repoName ?? "") to \(forkeeName ?? "")"

    case .DeleteEvent:
      let deleteEventPayload = event.payload as? DeleteEventPayload
      let deletedType = deleteEventPayload?.ref_type ?? ""
      let deletedRef = deleteEventPayload?.ref ?? ""
      desc = "\(actor) deleted \(deletedType) \(deletedRef) at \(repoName ?? "") "

    case .PullRequestEvent:
      guard let prPayload = event.payload as? PullRequestEventPayload else { break }
      var action = prPayload.action
      if prPayload.pull_request.merged == true && action == "closed" {
        action = "merged"
      }
      let prName = prPayload.pull_request.base.repo.full_name
      let prNum = "\(prPayload.pull_request.numbers.number)"
      let prURL = prPayload.pull_request.urls.url
      let prFullName = "\(prName)#\(prNum)"
      urls[prFullName] = prURL.appendingPathComponent(URLTargetStrings.pullRequest.rawValue)
      desc = "\(actor) \(action) pull request \(prFullName)"

    case .IssuesEvent:
      guard let iePayload = event.payload as? IssueEventPayload else { break }
      let action = iePayload.action
      desc = "\(actor) \(action) issue \(repoName ?? "")"

    case .PullRequestReviewCommentEvent:
      guard let icePayload = event.payload as? PullRequestReviewCommentEventPayload else { break }
      let action = icePayload.action
      let repo = icePayload.pull_request.base.repo.full_name
      let prNumber = icePayload.pull_request.numbers.number
      let prName = "\(repo)#\(prNumber)"
      let prURL = icePayload.pull_request.urls.url
      urls[prName] = prURL.appendingPathComponent(URLTargetStrings.pullRequest.rawValue)
      desc = "\(actor) \(action) comment on pull request \(prName)"

    case .CreateEvent:
      guard let payload = event.payload as? CreateEventPayload else { break }
      desc = "\(actor) created \(payload.ref_type) \(payload.ref ?? "") at \(repoName ?? "")"

    case .ReleaseEvent:
      desc = "\(actor) released at \(repoName ?? "")"

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
    guard let target = URLTargetStrings.init(rawValue: link.lastPathComponent) else { return nil }
    let targetURL = link.deletingLastPathComponent()
    switch target {
    case .user:
      let vc = UserProfileViewController.instantiate()
      vc.set(userUrl: targetURL)
      return vc
    case .repository:
      let vc = RepositoryViewController.instantiate()
      vc.set(repoURL: targetURL)
      return vc
    case .branchContent:
      let vc = RepositoryContentTableViewController.instantiate()
      vc.set(contentURL: targetURL)
      return vc
    case .issue:
      let vc = IssueTableViewController.instantiate()
      vc.set(issue: targetURL)
      return vc
    case .pullRequest:
      let vc = PullRequestTableViewController.instantiate()
      vc.set(pullRequest: targetURL)
      return vc
    }
  }
}










