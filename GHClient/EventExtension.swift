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
    
        switch event.type {
        case .PushEvent:
          let actorName = event.actor.login
          let actorURL = event.actor.url
          urls[actorName] = actorURL


          guard
            let repoName = event.repo?.name,
            let repoURL = event.repo?.url else  { break }
          urls[repoName] = repoURL


          guard let pushEventPayload = event.payload as? PushEventPayload,
            let branchName = pushEventPayload.ref.components(separatedBy: "/").last
          else { break }
          let components = repoName.components(separatedBy: "/")
          guard let owner = components.first, let repo = components.last else { break }

          let branchContentURL = AppEnvironment.current.apiService.contentURL(of: owner, and: repo, and: branchName)

          urls[branchName] = branchContentURL

          desc = "\(actorName) pushed to \(branchName) at \(repoName)"
        default:
          break
        }
    
        return (desc, urls)
  }
}

//extension GHEvent {
//  internal var eventDescription: URLAttachedEventDescription {
//    var desc = ""
//    var urls: [String: URL] = [:]
//
//    switch self.type {
//    case .PushEvent:
//      let actorName = self.actor.login
//      let actorURL = self.actor.url
//      let repoName = self.repo.name
//      let reopURL = self.repo.url
//
//      if let pushEventPayload = self.payload as? PushEventPayload {
//        let branchName = pushEventPayload.ref
//      }
//
//      desc = ""
//    default:
//      break
//    }
//    
//
//    return (desc, urls)
//  }
//}
