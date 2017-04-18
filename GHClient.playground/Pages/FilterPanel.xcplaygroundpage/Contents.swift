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

let panelView = FilterPanelView(frame: CGRect(x: 0, y: 0, width: 200, height: 400))

let label = Grid<Filter>.primitive(CGSize.one, .element(.dropDownList(["color": UIColor.red])))

let panel = label ||| label --- label ||| label

panelView.panel = panel

panelView.backgroundColor = UIColor.white

panelView.setNeedsLayout()

PlaygroundPage.current.liveView = panelView







//: [Next](@next)
