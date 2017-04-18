//
//  Filter.swift
//  GHClient
//
//  Created by Pi on 17/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import Foundation

public enum Filter {
  case dropDownList([String: Any])
  case radioButton([String: Any])
  case checkBoxButton([String: Any])
  case rangeSlider([String: Any])
  case label([String: Any])

  public static func filter(named name: String) -> Filter {
    switch name {
    case "label":
      return .label(["color": UIColor.red])
    default:
      return .label(["color": UIColor.red])
    }
  }
}


public struct FilterPanel {
  public static let filterPanel1: Grid<Filter> = {

    let label = Grid<Filter>.primitive(CGSize.one, .element(.label(["color": UIColor.red])))

    let panel = Grid<Filter>.align(CGPoint.topCenter, label)

    return panel
  }()
}



extension String {

  fileprivate var singularGrid: Grid<Filter> {
    let values = self.components(separatedBy: "><")
    guard values.count >= 1 && values.count <= 3 else { fatalError("keyboard layout syntax error") }
    let key = Filter.filter(named: values[0])
    if values.count == 1 {
      return .primitive(CGSize.one, .element(key))
    } else if values.count == 2 {
      guard let w = Double(values[1]) else { fatalError("keyboard layout syntax error") }
      return .primitive(CGSize(width: w, height: 1), .element(key))
    } else if values.count == 3 {
      guard let w = Double(values[1]) else { fatalError("keyboard layout syntax error") }
      guard let h = Double(values[2]) else { fatalError("keyboard layout syntax error") }
      return .primitive(CGSize(width: w, height: h), .element(key))
    } else {
      fatalError("keyboard layout syntax error")
    }
  }

  fileprivate var grid: Grid<Filter> {
    return self.singularGrid
  }

  fileprivate static func ||| (g: CGFloat, r: String) -> Grid<Filter> {
    return .beside(Grid(), g, r.grid)
  }

  fileprivate static func ||| (l: String, g: CGFloat) -> Grid<Filter> {
    return .beside(l.grid, g, Grid())
  }

  fileprivate static func ||| (l: String, r: String) -> Grid<Filter> {
    return .beside(l.grid, 0, r.grid)
  }

  fileprivate static func ||| (l: String, r: Grid<Filter>) -> Grid<Filter> {
    return .beside(l.grid, 0, r)
  }

  fileprivate static func ||| (l: Grid<Filter>, r: String) -> Grid<Filter> {
    return .beside(l, 0, r.grid)
  }


  fileprivate static func --- (g: CGFloat, r: String) -> Grid<Filter> {
    return .below(Grid(), g, r.grid)
  }

  fileprivate static func --- (l: String, g: CGFloat) -> Grid<Filter> {
    return .below(l.grid, g, Grid())
  }


  fileprivate static func --- (l: String, r: String) -> Grid<Filter> {
    return .below(l.grid, 0, r.grid)
  }

  fileprivate static func --- (l: Grid<Filter>, r: String) -> Grid<Filter> {
    return .below(l, 0, r.grid)
  }

  fileprivate static func --- (l: String, r: Grid<Filter>) -> Grid<Filter> {
    return .below(l.grid, 0, r)
  }
}
