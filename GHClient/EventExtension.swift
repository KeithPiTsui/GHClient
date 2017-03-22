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

