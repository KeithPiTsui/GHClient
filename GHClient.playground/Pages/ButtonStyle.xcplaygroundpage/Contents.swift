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

let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 400))
containerView |> UIView.lens.backgroundColor .~ UIColor.white
let btn = UIButton()
btn.translatesAutoresizingMaskIntoConstraints = false
containerView.addSubview(btn)
btn.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
btn.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

let checkboxButtonStyle =
  baseButtonStyle
    <> UIButton.lens.layer.borderColor .~ UIColor.green.cgColor
    <> UIButton.lens.layer.borderWidth .~ 1.0
    <> UIButton.lens.image(forState: .normal) %~ { _ in image(named: "check", tintColor: .green) }
    <> UIButton.lens.contentEdgeInsets %~~ { _ in .init(topBottom: 3, leftRight: 3)}

_ = btn
  |> checkboxButtonStyle



PlaygroundPage.current.liveView = containerView



//: [Next](@next)
