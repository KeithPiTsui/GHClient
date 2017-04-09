//
//  PushEventExtension.swift
//  GHClient
//
//  Created by Pi on 22/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import GHAPI


extension GHEvent {
  internal var summary: URLAttachedDescription { return GHEventDescriber.describe(event: self) }
}

/// The cases of different strings which will be attached at the end of a url 
/// for identifying the target view controller to go when user tapped on link.
fileprivate enum URLTargetStrings: String {
  case user
  case repository
  case issue
  case commit
  case branchContent
  case pullRequest
  case organization
  case team
  case label
  case milestone
  case projectCard
  case project
  case projectColumn
  case html
}




// MARK: -
// MARK: Event Description for AttributedLabel
internal enum GHEventDescriber {
  internal static func describe(event: GHEvent) -> URLAttachedDescription {
    var desc = ""
    var urls: [String: URL] = [:]

    let actor = event.actor.login
    let actorURL = event.actor.url.appendingPathComponent(URLTargetStrings.user.rawValue)
    urls[actor] = actorURL

    let repoName = event.repo?.name
    let repoURL = event.repo?.url.appendingPathComponent(URLTargetStrings.repository.rawValue)
    if let rn = repoName {
      urls[rn] = repoURL
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
      guard let pushEventPayload = event.payload as? ForkEventPayload else { break }
      let forkeeName = pushEventPayload.forkee.full_name
      urls[forkeeName] = pushEventPayload.forkee.urls.url.appendingPathComponent(URLTargetStrings.repository.rawValue)
      desc = "\(actor) forked \(repoName ?? "") to \(forkeeName )"

    case .DeleteEvent:
      guard let deleteEventPayload = event.payload as? DeleteEventPayload else { break }
      let deletedType = deleteEventPayload.ref_type
      let deletedRef = deleteEventPayload.ref
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
      desc = "\(actor) \(action) commented on pull request \(prName)"

    case .CreateEvent:
      guard let payload = event.payload as? CreateEventPayload else { break }
      desc = "\(actor) created \(payload.ref_type) \(payload.ref ?? "") at \(repoName ?? "")"

    case .ReleaseEvent:
      desc = "\(actor) released at \(repoName ?? "")"

    case .CommitCommentEvent:
      guard let payload = event.payload as? CommitCommentEventPayload else { break }
      let commitID = payload.comment.commit_id.last(8)
      let commitURL = payload.repository?.urls.commits_url
        .appendingPathComponent(payload.comment.commit_id)
        .appendingPathComponent(URLTargetStrings.commit.rawValue)
      urls[commitID] = commitURL
      desc = "\(actor) commented on commit \(commitID) of \(repoName ?? "")"

    case .GollumEvent:
      desc = "\(actor) updated pages on \(repoName ?? "")"

    case .LabelEvent:
      guard  let payload = event.payload as? LabelEventPayload else { break }
      let label = payload.label.name
      let labelURL = payload.label.url.appendingPathComponent(URLTargetStrings.label.rawValue)
      urls[label] = labelURL
      let repoName = payload.repository.full_name
      let repoURL = payload.repository.urls.url.appendingPathComponent(URLTargetStrings.repository.rawValue)
      urls[repoName] = repoURL
      desc = "\(actor) \(payload.action) label \(label) on \(repoName)"

    case .MemberEvent:
      guard let payload = event.payload as? MemberEventPayload else { break }
      let user = payload.member.login
      let userURL = payload.member.urls.url.appendingPathComponent(URLTargetStrings.user.rawValue)
      urls[user] = userURL
      desc = "\(actor) \(payload.action) \(user) to \(repoName ?? "")"

    case .MembershipEvent:
      guard let payload = event.payload as? MembershipEventPayload else { break }
      let member = payload.member.login
      let memberURL = payload.member.urls.url.appendingPathComponent(URLTargetStrings.user.rawValue)
      urls[member] = memberURL
      let team = payload.team.name
      let teamURL =  payload.team.url.appendingPathComponent(URLTargetStrings.team.rawValue)
      urls[team] = teamURL
      let org = payload.organization.login
      let orgURL = payload.organization.url.appendingPathComponent(URLTargetStrings.organization.rawValue)
      urls[org] = orgURL
      desc = "\(actor) \(payload.action) \(member) of \(team) in \(org)"

    case .MilestoneEvent:
      guard let payload = event.payload as? MilestoneEventPayload else { break }
      let milestone = "mile stone"
      let miletoneURL = payload.milestone.url.appendingPathComponent(URLTargetStrings.milestone.rawValue)
      urls[milestone] = miletoneURL
      desc = "\(actor) \(payload.action) \(milestone) of \(repoName ?? "")"

    case .OrganizationEvent:
      guard let payload = event.payload as? OrganizationEventPayload else { break }
      let action = payload.action
      let member = payload.membership.user.login
      let memberURL = payload.membership.user.urls.url.appendingPathComponent(URLTargetStrings.user.rawValue)
      urls[member] = memberURL
      let org = payload.organization.login
      let orgURL = payload.organization.url.appendingPathComponent(URLTargetStrings.organization.rawValue)
      urls[org] = orgURL

      if action == "member_added" {
        desc = "\(actor) add \(member) to \(org)"
      } else if action == "member_removed" {
        desc = "\(actor) remove \(member) from \(org)"
      } else if action == "member_invited" {
        let user = payload.invitation.login
        let userURL = AppEnvironment.current.apiService.userURL(with: user).appendingPathComponent(URLTargetStrings.user.rawValue)
        urls[user] = userURL
        desc = "\(actor) invited \(user) to \(org)"
      }

    case .OrgBlockEvent:
      guard let payload = event.payload as? OrgBlockEventPayload else { break }
      let org = payload.organization.login
      let orgURL = payload.organization.url.appendingPathComponent(URLTargetStrings.organization.rawValue)
      urls[org] = orgURL
      let user = payload.blocked_user.login
      let userURL = payload.blocked_user.urls.url.appendingPathComponent(URLTargetStrings.user.rawValue)
      urls[user] = userURL
      desc = "\(org) \(payload.action) \(user)"

    case .ProjectCardEvent:
      guard let payload = event.payload as? ProjectCardEventPayload else { break }
      let projectCard = "project card"
      let projectCardURL = payload.project_card.url.appendingPathComponent(URLTargetStrings.projectCard.rawValue)
      urls[projectCard] = projectCardURL
      let org = payload.organization.login
      let orgURL = payload.organization.url.appendingPathComponent(URLTargetStrings.organization.rawValue)
      urls[org] = orgURL
      desc = "\(actor) \(payload.action) \(projectCard) of \(repoName ?? "")"

    case .ProjectColumnEvent:
      guard let payload = event.payload as? ProjectColumnEventPayload else { break }
      let user = payload.sender.login
      let userURL = payload.sender.urls.url.appendingPathComponent(URLTargetStrings.user.rawValue)
      urls[user] = userURL
      let projectColumn = payload.project_column.name
      let projectColumnURL = payload.project_column.url.appendingPathComponent(URLTargetStrings.projectColumn.rawValue)
      urls[projectColumn] = projectColumnURL
      let reponame = payload.repository.full_name
      let repoURL = payload.repository.urls.url.appendingPathComponent(URLTargetStrings.repository.rawValue)
      urls[reponame] = repoURL
      desc = "\(user) \(payload.action) project column \(projectColumn) on \(reponame)"

    case .ProjectEvent:
      guard let payload = event.payload as? ProjectEventPayload else { break }
      let user = payload.sender.login
      let userURL = payload.sender.urls.url.appendingPathComponent(URLTargetStrings.user.rawValue)
      urls[user] = userURL
      let project = payload.project.name
      let projectURL = payload.project.url.appendingPathComponent(URLTargetStrings.project.rawValue)
      urls[project] = projectURL
      let reponame = payload.repository.full_name
      let repoURL = payload.repository.urls.url.appendingPathComponent(URLTargetStrings.repository.rawValue)
      urls[reponame] = repoURL
      desc = "\(user) \(payload.action) project \(project) on \(reponame)"

    case .PublicEvent:
      guard let payload = event.payload as? PublicEventPayload else { break }
      let user = payload.sender.login
      let userURL = payload.sender.urls.url.appendingPathComponent(URLTargetStrings.user.rawValue)
      urls[user] = userURL
      let reponame = payload.repository.full_name
      let repoURL = payload.repository.urls.url.appendingPathComponent(URLTargetStrings.repository.rawValue)
      urls[reponame] = repoURL
      desc = "\(user) published \(reponame)"

    case .PullRequestReviewEvent:
      guard let payload = event.payload as? PullRequestReviewEventPayload else { break }
      let user = payload.sender.login
      let userURL = payload.sender.urls.url.appendingPathComponent(URLTargetStrings.user.rawValue)
      urls[user] = userURL
      let reponame = payload.repository.full_name
      let repoURL = payload.repository.urls.url.appendingPathComponent(URLTargetStrings.repository.rawValue)
      urls[reponame] = repoURL
      let pullRequest = "#\(payload.pull_request.numbers.number)"
      let pullRequestURL = payload.pull_request.urls.url.appendingPathComponent(URLTargetStrings.pullRequest.rawValue)
      urls[pullRequest] = pullRequestURL
      desc = "\(user) \(payload.action) review of \(reponame)\(pullRequest)"

    case .RepositoryEvent:
      guard let payload = event.payload as? RepositoryEventPayload else { break }
      let user = payload.sender.login
      let userURL = payload.sender.urls.url.appendingPathComponent(URLTargetStrings.user.rawValue)
      urls[user] = userURL
      let reponame = payload.repository.full_name
      let repoURL = payload.repository.urls.url.appendingPathComponent(URLTargetStrings.repository.rawValue)
      urls[reponame] = repoURL
      desc = "\(user) \(payload.action) \(reponame)"

    case .WatchEvent:
      guard let payload = event.payload as? WatchEventPayload else { break }
      let user = payload.sender.login
      let userURL = payload.sender.urls.url.appendingPathComponent(URLTargetStrings.user.rawValue)
      urls[user] = userURL
      let reponame = payload.repository.full_name
      let repoURL = payload.repository.urls.url.appendingPathComponent(URLTargetStrings.repository.rawValue)
      urls[reponame] = repoURL
      desc = "\(user) starred \(reponame)"

    case .IssuesEvent:
      guard let payload = event.payload as? IssueEventPayload else { break }
      urls["issue"] = payload.issue.urls.url.appendingPathComponent(URLTargetStrings.issue.rawValue)
      desc = "\(actor) \(payload.action) issue on \(repoName ?? "")"

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
    case .commit:
      let vc = CommitTableViewController.instantiate()
      vc.set(commit: targetURL)
      return vc
    default:
      return nil
    }
  }
}










