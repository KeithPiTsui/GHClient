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

let checkbox = Grid<Filter>.primitive(CGSize.one,
                                      .element(.checkBoxButton(["style": checkboxButtonStyle])))

let checkbox2 = Grid<Filter>.primitive(CGSize.one,
                                       .element(.checkBoxButton(["style": lightNavyButtonStyle])))

let checkbox3 = Grid<Filter>.primitive(CGSize.one,
                                       .element(.checkBoxButton(["style": blackButtonStyle])))

let checkbox4 = Grid<Filter>.primitive(CGSize.one,
                                       .element(.checkBoxButton(["style": twitterButtonStyle])))

let panel = checkbox ||| checkbox2 --- checkbox3 ||| checkbox4

panelView.panel = panel

panelView.backgroundColor = UIColor.white

panelView.setNeedsLayout()

PlaygroundPage.current.liveView = panelView







//: [Next](@next)
