//
//  CGRect-Extension.swift
//  GHClient
//
//  Created by Pi on 09/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

extension CGRect {
    internal var leftConner: CGPoint {
        return CGPoint(x: origin.x, y: origin.y + height)
    }
}
