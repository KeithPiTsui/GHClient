//
//  CGSizeExt.swift
//  ExtSwift
//
//  Created by Pi on 19/02/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

extension CGSize {
    public init(_ width:CGFloat, _ height:CGFloat) {
        self.init(width:width, height:height)
    }
    public func sizeByDelta(dw:CGFloat, dh:CGFloat) -> CGSize {
        return CGSize(self.width + dw, self.height + dh)
    }
}

extension CGSize {
    public func fit(into rect: CGRect, alignment: CGPoint) -> CGRect {
        let scale = min(rect.width / width, rect.height / height)
        let targetSize = scale * self
        let spacerSize = alignment.size * (rect.size - targetSize)
        return CGRect(origin: rect.origin + spacerSize.point, size: targetSize)
    }
    
    public static func * (l: CGFloat, r: CGSize) -> CGSize {
        return CGSize(width: l * r.width, height: l * r.height)
    }
    
    public static func * (l: CGSize, r: CGSize) -> CGSize {
        return CGSize(width: l.width * r.width, height: l.height * r.height)
    }
    
    public static func - (l: CGSize, r: CGSize) -> CGSize {
        return CGSize(width: l.width - r.width, height: l.height - r.height)
    }
    
    public var point: CGPoint { return CGPoint(x: self.width, y: self.height) }
    
    public static let one: CGSize = CGSize(width: 1, height: 1)
}

extension CGRect {
  public func splitThree(firstFraction: CGFloat, lastFraction: CGFloat, isHorizontal: Bool) ->(CGRect, CGRect) {
    if isHorizontal {
      let w1 = self.width * firstFraction
      let c1 = CGRect(x: self.origin.x, y: self.origin.y, width: w1, height: self.height)
      let w2 = self.width * lastFraction
      let c2 = CGRect(x: self.origin.x + self.width - w2, y: self.origin.y, width: w2, height: self.height)
      return (c1, c2)
    } else {
      let h1 = self.height * firstFraction
      let c1 = CGRect(x: self.origin.x, y: self.origin.y, width: self.width, height: h1)
      let h2 = self.height * lastFraction
      let c2 = CGRect(x: self.origin.x, y: self.origin.y + self.height - h2, width: self.width, height: h2)
      return (c1, c2)
    }
  }
}
