//
//  MarkupViewerViewModel.swift
//  GHClient
//
//  Created by Pi on 21/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import Prelude
import GHAPI
import Down

internal protocol MarkupViewerViewModelInputs {

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  /// Call when vc received a url for markup
  func set(markup url: URL)
}

internal protocol MarkupViewerViewModelOutputs {

  var htmlString: Signal<String, NoError> { get }
}

internal protocol MarkupViewerViewModelType {
  var inputs: MarkupViewerViewModelInputs { get }
  var outpus: MarkupViewerViewModelOutputs { get }
}


internal final class MarkupViewerViewModel:
MarkupViewerViewModelType,
MarkupViewerViewModelInputs,
MarkupViewerViewModelOutputs {

  init() {
    let url = Signal.combineLatest(self.setMarkupURLProperty.signal.skipNil(), self.viewDidLoadProperty.signal)
      .map(first)
    self.htmlString = url.observeInBackground()
      .map { try? String(contentsOf: $0) }
      .skipNil()
      .map { try? Down(markdownString: $0).toHTML()}
      .skipNil()
  }

  fileprivate let setMarkupURLProperty = MutableProperty<URL?>(nil)
  public func set(markup url: URL) {
    self.setMarkupURLProperty.value = url
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
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let viewWillAppearProperty = MutableProperty<Bool?>(nil)
  internal func viewWillAppear(animated: Bool) {
    self.viewWillAppearProperty.value = animated
  }

  internal let htmlString: Signal<String, NoError>

  internal var inputs: MarkupViewerViewModelInputs { return self }
  internal var outpus: MarkupViewerViewModelOutputs { return self }
}
