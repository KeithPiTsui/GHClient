//
//  RepositoryContentViewModel.swift
//  GHClient
//
//  Created by Pi on 21/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import ReactiveExtensions
import GHAPI
import Prelude
import AVKit
import AVFoundation

internal protocol RepositoryContentViewModelInputs {

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  /// Call when vc is set with repo and branch
  func set(repo: Repository, and branch: BranchLite)

  /// Call when vc is set with content url
  func set(contentURL: URL)

  /// Call when user tapped on content
  func tapped(on content: Content)
}

internal protocol RepositoryContentViewModelOutputs {

  var contents: Signal<[Content], NoError> { get }

  var presentMediaVC: Signal<AVPlayerViewController, NoError> {get}

  var presentSourceCodeViewer: Signal<HighlighterViewController, NoError> { get }

  var presentMarkupViewer: Signal<MarkupViewerViewController, NoError> { get }

  var presentAlert: Signal<UIAlertController, NoError> { get }

  var presentDocumentController: Signal<UIDocumentInteractionController, NoError> {get}

  var pushNextDirectory: Signal<RepositoryContentTableViewController, NoError> { get }
}

internal protocol RepositoryContentViewModelType {
  var inputs: RepositoryContentViewModelInputs { get }
  var outpus: RepositoryContentViewModelOutputs { get }
}


internal final class RepositoryContentViewModel:
  RepositoryContentViewModelType,
  RepositoryContentViewModelInputs,
RepositoryContentViewModelOutputs {

  init() {
    let content1  = Signal.combineLatest(self.setRepoAndBranchProperty.signal.skipNil(),
                                         self.viewDidLoadProperty.signal)
      .map(first)
      .map { (repo, branch) in
        return AppEnvironment.current.apiService.contents(of: repo, ref: branch.name).single()?.value}
      .skipNil()

    let content2 = Signal.combineLatest(self.setContentURLProperty.signal.skipNil(),
                                        self.viewDidLoadProperty.signal)
      .map(first)
      .map { (url) in
        return AppEnvironment.current.apiService.contents(referredBy: url).single()?.value}
      .skipNil()

    self.contents = Signal.merge(content1, content2)

    let file = self.tappedOnContentProperty.signal.skipNil().filter{$0.type == "file"}

    let fileTypeAndUrl = file
      .map { (content) -> (FileTypeCategorizer.FileTypeCategory, URL?) in
        (FileTypeCategorizer.fileTypeCategory(of: content.name), content.download_url)}

    let dir = self.tappedOnContentProperty.signal.skipNil().filter{$0.type == "dir"}
//    let submodule = self.tappedOnContentProperty.signal.skipNil().filter{$0.type == "submodule"}

    let markup = fileTypeAndUrl.filter{$0.0 == .markup}.map(second).skipNil()
    let audio = fileTypeAndUrl.filter{ $0.0 == .audio}.map(second).skipNil()
    let video = fileTypeAndUrl.filter{ $0.0 == .video}.map(second).skipNil()
    let documment = fileTypeAndUrl.filter{ $0.0 == .documment}.map(second).skipNil()
    let image = fileTypeAndUrl.filter{ $0.0 == .image}.map(second).skipNil()
    let others = fileTypeAndUrl.filter{ $0.0 == .others}.map{ _ in () }
    let nilUrl = fileTypeAndUrl.filter{ $0.1 == nil }.map { _ in ()}

    let sourceCode = file.filter{FileTypeCategorizer.fileTypeCategory(of: $0.name) == .sourceCode}

    self.pushNextDirectory = dir
      .map{
        let vc = RepositoryContentTableViewController.instantiate()
        vc.set(contentURL:$0.url)
        return vc
    }

    self.presentMarkupViewer = markup
      .map {
        let vc = MarkupViewerViewController.instantiate()
        vc.set(markup: $0)
        return vc
    }

    self.presentMediaVC = Signal.merge(audio, video)
      .map {
        let player = AVPlayer(url: $0)
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        return playerVC
    }

    let sourceCodeViewer = sourceCode
      .map{ (content) -> HighlighterViewController? in
        let vc = HighlighterViewController.instantiate()
        if let contentStr = content.plainContent {
          vc.code = contentStr
        } else if let downloadURL = content.download_url,
          let sourceCode = try? String(contentsOf: downloadURL) {
          vc.code = sourceCode
        } else {
          return nil
        }
        vc.language = (content.name as NSString).pathExtension
        return vc
    }

    self.presentSourceCodeViewer = sourceCodeViewer.skipNil()

    self.presentDocumentController = Signal.merge(documment,image)
      .map(UIDocumentInteractionController.init)

    let noSourceCodeViewer = sourceCodeViewer.filter{$0 == nil}.map {_ in ()}

    self.presentAlert = Signal.merge(others, nilUrl, noSourceCodeViewer)
      .map {
        let alert = UIAlertController(title: "Cannot open this File", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        return alert
    }
  }



  fileprivate let tappedOnContentProperty = MutableProperty<Content?>(nil)
  public func tapped(on content: Content) {
    self.tappedOnContentProperty.value = content
  }

  fileprivate let setContentURLProperty = MutableProperty<URL?>(nil)
  public func set(contentURL: URL) {
    self.setContentURLProperty.value = contentURL
  }

  fileprivate let setRepoAndBranchProperty = MutableProperty<(Repository, BranchLite)?>(nil)
  public func set(repo: Repository, and branch: BranchLite) {
    self.setRepoAndBranchProperty.value = (repo, branch)
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

  internal let contents: Signal<[Content], NoError>

  internal let presentMediaVC: Signal<AVPlayerViewController, NoError>
  internal let presentSourceCodeViewer: Signal<HighlighterViewController, NoError>
  internal let presentMarkupViewer: Signal<MarkupViewerViewController, NoError>
  internal let presentAlert: Signal<UIAlertController, NoError>
  internal let pushNextDirectory: Signal<RepositoryContentTableViewController, NoError>
  internal let presentDocumentController: Signal<UIDocumentInteractionController, NoError>

  internal var inputs: RepositoryContentViewModelInputs { return self }
  internal var outpus: RepositoryContentViewModelOutputs { return self }
}
