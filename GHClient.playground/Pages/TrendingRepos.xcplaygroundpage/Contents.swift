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
let (parent, _) = playgroundControllers(device: .phone4_7inch,
                                        orientation: .portrait,
                                        child: vc,
                                        style: .tabBar)

PlaygroundPage.current.liveView = parent


