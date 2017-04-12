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

  /**
   Call from the controller's `tableView:willDisplayCell:forRowAtIndexPath` method.

   - parameter row:       The 0-based index of the row displaying.
   - parameter totalRows: The total number of rows in the table view.
   */
  func willDisplayRow(_ row: Int, outOf totalRows: Int)
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

    let isCloseToBottom = self.willDisplayRowProperty.signal.skipNil()
      .map { row, total in total > 3 && row >= total - 2 }
      .skipRepeats()
      .filter(isTrue)
      .map{ _ in ()}

    let requestFirstPage = Signal
      .merge(
        self.userSessionStartedProperty.signal,
        self.viewWillAppearProperty.signal.skipNil().filter(isFalse).map{_ in ()},
        self.refreshEventsProperty.signal
      )
      .filter { AppEnvironment.current.currentUser != nil }

    let (paginatedActivities, isLoading, pageCount)
      = paginate(requestFirstPageWith: requestFirstPage,
             requestNextPageWhen: isCloseToBottom,
             clearOnNewRequest: false,
             skipRepeats: false,
             valuesFromEnvelope: { (envelope: GHServiceReturnType<[GHEvent]>) -> [GHEvent] in envelope.0},
             cursorFromEnvelope: { (envelope: GHServiceReturnType<[GHEvent]>) -> URL? in envelope.1.links?.next },
             requestFromParams: { (_) -> SignalProducer<GHServiceReturnType<[GHEvent]>, ErrorEnvelope> in
              guard let user = AppEnvironment.current.currentUser else {
                return SignalProducer.init(error: ErrorEnvelope.unknownError)
              }
              return AppEnvironment.current.apiService.receivedEventsWithResponseHeader(of: user)},
             requestFromCursor: { (url) -> SignalProducer<GHServiceReturnType<[GHEvent]>, ErrorEnvelope> in
              guard let url = url else { return SignalProducer.init(error: ErrorEnvelope.unknownError) }
              return AppEnvironment.current.apiService.receivedEventsWithResponseHeader(of: url)})

    let activities = paginatedActivities
      .scan([GHEvent]()) { acc, next in
        !next.isEmpty
          ? (acc + next).distincts().sorted { $0.id > $1.id }
          : next
    }


    let eventRequest = Signal.merge(self.viewDidLoadProperty.signal, self.refreshEventsProperty.signal)
    self.loading = eventRequest

    let events = eventRequest.observe(on: QueueScheduler())
      .map { () -> [GHEvent]? in
        guard let user = AppEnvironment.current.currentUser else { return nil }
        return AppEnvironment.current.apiService.events(of: user).single()?.value
      }.skipNil()

    let receivedEvents = activities
//      eventRequest.observe(on: QueueScheduler())
//      .map { () -> [GHEvent]? in
//        guard let user = AppEnvironment.current.currentUser else { return nil }
//        return AppEnvironment.current.apiService.receivedEvents(of: user).single()?.value
//      }.skipNil()

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

    self.pushViewController
      = self.tappOnEventWithLinkProperty.signal.skipNil()
        .map(GHEventDescriber.viewController)
        .skipNil()
  }

  fileprivate let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
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
  internal func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }
  fileprivate let userSessionEndedProperty = MutableProperty(())
  internal func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let viewWillAppearProperty = MutableProperty<Bool?>(nil)
  internal func viewWillAppear(animated: Bool) {
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



