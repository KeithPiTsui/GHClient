//
//  FilterPanel.swift
//  GHClient
//
//  Created by Pi on 17/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

public final class FilterPanelView: UIView {


  public var panel: Grid<Filter> = FilterPanel.filterPanel1  {
    didSet {
      boundSize = nil
      self.setNeedsLayout()
    }
  }

  /// To record bound change
  private var boundSize: CGSize?

  override public func layoutSubviews() {
    super.layoutSubviews()
    guard bounds.width != 0 && bounds.height != 0 else { return }
    guard boundSize == nil || bounds.size.equalTo(boundSize!) == false else { return }

    boundSize = bounds.size
    subviews.forEach{ $0.removeFromSuperview() }
    layout(panel, in: bounds)

  }


}

extension FilterPanelView {
  func layout(_ primitive: Primitive<Filter>, in frame: CGRect) {
    if case let .element(k) = primitive {
      switch k {
      case .label(_):
        let lab = UILabel(frame: frame)
        lab.text = "testing"
        lab.textColor = UIColor.red
        self.addSubview(lab)
      default:
        break;
      }

    }
  }

  func layout(_ diagram: Grid<Filter>, in bounds: CGRect) {
    switch diagram {
    case let .primitive(size, primitive):
      let bounds = size.fit(into: bounds, alignment: .center)
      layout(primitive, in: bounds)

    case .align(let alignment, let diagram):
      print("align")
      let bounds = diagram.size.fit(into: bounds, alignment: alignment)
      layout(diagram, in: bounds)

    case let .beside(l, _, r):
      let (lBounds, rBounds) = bounds.splitThree(firstFraction: l.size.width / diagram.size.width,
                                                 lastFraction: r.size.width / diagram.size.width,
                                                 isHorizontal: true)
      layout(l, in: lBounds)
      layout(r, in: rBounds)

    case .below(let top, _, let bottom):
      let (tBounds, bBounds) = bounds.splitThree(firstFraction: top.size.height / diagram.size.height,
                                                 lastFraction: bottom.size.height / diagram.size.height,
                                                 isHorizontal: false)
      layout(top, in: tBounds)
      layout(bottom, in: bBounds)
    default:
      break
    }
  }
}
