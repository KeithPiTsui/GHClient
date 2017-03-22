//
//  ActivitiesViewModel.swift
//  GHClient
//
//  Created by Pi on 13/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result
import GHAPI

internal enum ActivitySegment: String {
  case Events
  case ReceivedEvents
}
extension ActivitySegment: HashableEnumCaseIterating{}

internal protocol ActivitesViewModelInputs {
  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when user tap scope segment to change scope
  func segmentChanged(index: Int)

  /// Call when vc is set with an segment value
  func set(segment: ActivitySegment)

  /// Call when user request lastest event
  func refreshEvents()

  /// Call when user tapped on a link on event
  func tapped(on event: GHEvent, with link: URL)
}

internal protocol ActivitesViewModelOutputs {

  var segments: Signal<[ActivitySegment], NoError> { get }

  var selectedSegment: Signal<Int, NoError> {get}

  var events: Signal<[GHEvent], NoError> {get}

  var receivedEvents: Signal<[GHEvent], NoError> {get}

  var loading: Signal<(), NoError> { get }

  var loaded: Signal<(), NoError> { get }

  var pushViewController: Signal<UIViewController, NoError> { get}
}

internal protocol ActivitesViewModelType {
  var inputs: ActivitesViewModelInputs { get }
  var outputs: ActivitesViewModelOutputs { get }
}

internal final class ActivitesViewModel: ActivitesViewModelType, ActivitesViewModelInputs, ActivitesViewModelOutputs {

  fileprivate static let allSegments = ActivitySegment.allCases

  init() {
    let eventRequest = Signal.merge(self.viewDidLoadProperty.signal, self.refreshEventsProperty.signal)
    self.loading = eventRequest

    let events = eventRequest.observe(on: QueueScheduler())
      .map { () -> [GHEvent]? in
        guard let user = AppEnvironment.current.currentUser else { return nil }
        return AppEnvironment.current.apiService.events(of: user).single()?.value
      }.skipNil()

    let receivedEvents = eventRequest.observe(on: QueueScheduler())
      .map { () -> [GHEvent]? in
        guard let user = AppEnvironment.current.currentUser else { return nil }
        return AppEnvironment.current.apiService.receivedEvents(of: user).single()?.value
      }.skipNil()

    let initialSelectedSegment = self.viewDidLoadProperty.signal
      .map {ActivitesViewModel.allSegments.index(of: .Events)}
      .skipNil()

    let laterSelectedSegment = self.setSegmentProperty.signal.skipNil()
      .map{ActivitesViewModel.allSegments.index(of: $0)}
      .skipNil()

    let selectedSegment = Signal.merge(initialSelectedSegment, laterSelectedSegment)
    let eventLoaded = Signal
      .combineLatest(
        events,
        self.viewWillAppearProperty.signal.skipNil(),
        selectedSegment)

    self.events = eventLoaded
      .filter {ActivitesViewModel.allSegments[$0.2] == ActivitySegment.Events}
      .map(first)

    let receivedEventLoaded = Signal
      .combineLatest(
        receivedEvents,
        self.viewWillAppearProperty.signal.skipNil(),
        selectedSegment)
    self.receivedEvents = receivedEventLoaded
      .filter {ActivitesViewModel.allSegments[$0.2] == ActivitySegment.ReceivedEvents}
      .map(first)

    self.loaded = Signal.merge(self.events, self.receivedEvents).map{_ in ()}

    self.segments = self.viewDidLoadProperty.signal.map {ActivitesViewModel.allSegments}
    self.selectedSegment = Signal.combineLatest(selectedSegment, self.viewWillAppearProperty.signal).map(first)

    let repoEvent = self.tappOnEventWithLinkProperty.signal.skipNil()
      .filter {$0.1.pathComponents.contains("repo")}
      .map(first)
    let userEvent = self.tappOnEventWithLinkProperty.signal.skipNil()
      .filter {$0.1.pathComponents.contains("user")}
      .map(first)
    let branchEvent = self.tappOnEventWithLinkProperty.signal.skipNil()
      .filter {$0.1.pathComponents.contains("branch")}
      .map(first)

    let repo = repoEvent.map { (event) -> UIViewController? in
      guard let repoURL = event.repo?.url else { return nil }
      let vc = RepositoryViewController.instantiate()
      vc.set(repoURL: repoURL)
      return vc
      }.skipNil()

    let user = userEvent.map { (event) -> UIViewController? in
      let username = event.actor.login
      let url = AppEnvironment.current.apiService.userURL(with: username)
      let vc = UserProfileViewController.instantiate()
      vc.set(userUrl: url)
      return vc
      }.skipNil()

    let branch = branchEvent.map { (event) -> UIViewController? in

      guard let repoURL = event.repo?.url else { return nil }
      guard let branch = (event.payload as? PushEventPayload)?.ref.components(separatedBy: "/").last
        else { return nil }

      guard let repo = AppEnvironment.current.apiService.repository(referredBy: repoURL).single()?.value
        else { return nil}

      let url = AppEnvironment.current.apiService.contentURL(of: repo, ref: branch)

      let vc = RepositoryContentTableViewController.instantiate()
      vc.set(contentURL: url)
      return vc
      }.skipNil()

    self.pushViewController = Signal.merge(repo, user, branch)

  }

  fileprivate let tappOnEventWithLinkProperty = MutableProperty<(GHEvent, URL)?>(nil)
  internal func tapped(on event: GHEvent, with link: URL) {
    self.tappOnEventWithLinkProperty.value = (event, link)
  }

  fileprivate let refreshEventsProperty = MutableProperty()
  internal func refreshEvents() {
    self.refreshEventsProperty.value = ()
  }

  fileprivate let setSegmentProperty = MutableProperty<ActivitySegment?>(nil)
  internal func set(segment: ActivitySegment) {
    self.setSegmentProperty.value = segment
  }

  internal func segmentChanged(index: Int) {
    self.setSegmentProperty.value = ActivitesViewModel.allSegments[index]
  }

  fileprivate let userSessionStartedProperty = MutableProperty(())
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }
  fileprivate let userSessionEndedProperty = MutableProperty(())
  public func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let viewWillAppearProperty = MutableProperty<Bool?>(nil)
  public func viewWillAppear(animated: Bool) {
    self.viewWillAppearProperty.value = animated
  }

  internal let loading: Signal<(), NoError>
  internal let loaded: Signal<(), NoError>
  internal let segments: Signal<[ActivitySegment], NoError>
  internal let selectedSegment: Signal<Int, NoError>
  internal let events: Signal<[GHEvent], NoError>
  internal let receivedEvents: Signal<[GHEvent], NoError>
  internal let pushViewController: Signal<UIViewController, NoError>
  
  internal var inputs: ActivitesViewModelInputs { return self }
  internal var outputs: ActivitesViewModelOutputs { return self }
}
