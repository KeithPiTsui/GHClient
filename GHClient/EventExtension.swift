//
//  PushEventExtension.swift
//  GHClient
//
//  Created by Pi on 22/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import GHAPI

internal typealias URLAttachedEventDescription = (desc: String, attachedURLs: [String: URL])

internal enum GHEventDescriber {
  internal static func describe(event: GHEvent) -> URLAttachedEventDescription {
    var desc = ""
    var urls: [String: URL] = [:]
    let baseURL = AppEnvironment.current.apiService.serverConfig.apiBaseUrl
    switch event.type {
    case .PushEvent:
      let actorName = event.actor.login
      urls[actorName] = baseURL.appendingPathComponent("user")

      guard
        let repoName = event.repo?.name
        else  { break }
      urls[repoName] = baseURL.appendingPathComponent("repo")

      guard
        let pushEventPayload = event.payload as? PushEventPayload,
        let branchName = pushEventPayload.ref.components(separatedBy: "/").last
        else { break }
      urls[branchName] = baseURL.appendingPathComponent("branch")

      desc = "\(actorName) pushed to \(branchName) at \(repoName)"
    default:
      break
    }

    return (desc, urls)
  }
}

extension GHEvent {
  internal var eventDescription: URLAttachedEventDescription {
    return GHEventDescriber.describe(event: self)
  }
}

extension GHEvent {
  internal var userUrl: URL {
    return self.actor.url
  }

  internal var repoUrl: URL? {
    return self.repo?.url
  }

  internal var branchUrl: URL? {
    guard let repoURL = self.repo?.url else { return nil }
    guard let branch = (self.payload as? PushEventPayload)?.ref.components(separatedBy: "/").last
      else { return nil }

    guard let repo = AppEnvironment.current.apiService.repository(referredBy: repoURL).single()?.value
      else { return nil}

    let url = AppEnvironment.current.apiService.contentURL(of: repo, ref: branch)
    return url
//    guard
//      let pushEventPayload = self.payload as? PushEventPayload,
//      let branchName = pushEventPayload.ref.components(separatedBy: "/").last
//      else { return nil }
//    let base = AppEnvironment.current.apiService.serverConfig.apiBaseUrl.absoluteString
//    guard let repo = self.repo?.name else { return nil }
//    let str = "\(base)/repos/\(repo)/contents?ref=\(branchName)"
//    return URL(string: str)
  }
}











