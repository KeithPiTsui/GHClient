//
//  OptionalUnwraper.swift
//  GHClient
//
//  Created by Pi on 27/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import Foundation

internal func unwrap<T>(value: Any)
  -> (unwrapped:T?, isOriginalType:Bool) {
    let mirror = Mirror(reflecting: value)
    let isOrgType = mirror.subjectType == Optional<T>.self
    if mirror.displayStyle != .optional {
      return (value as? T, isOrgType)
    }
    guard let firstChild = mirror.children.first else {
      return (nil, isOrgType)
    }
    return (firstChild.value as? T, isOrgType)
}
