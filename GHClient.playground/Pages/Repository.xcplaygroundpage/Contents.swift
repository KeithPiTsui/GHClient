//: [Previous](@previous)

import Foundation
import ReactiveCocoa
import ReactiveSwift
import ReactiveExtensions
import Prelude
import Prelude_UIKit
import Runes
import GHAPI
import PlaygroundSupport
@testable import GHClientFramework

AppEnvironment.initialize()
let vc = DiscoveryViewController.instantiate()
let (parent, _) = playgroundControllers(device: .phone4_7inch, orientation: .portrait, child: vc)

let frame = parent.view.frame |> CGRect.lens.size.height .~ 2200
PlaygroundPage.current.liveView = parent
parent.view.frame = frame

