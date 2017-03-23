//
//  UIResponderExtension.swift
//  GHClient
//
//  Created by Pi on 23/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

extension UIResponder {
  public static func firstDescedant<RPD: UIResponder>(_:RPD.Type) -> (UIResponder) -> RPD? {
    return { responder in
      var r: UIResponder? = responder
      while r != nil {
        if r is RPD { return r as? RPD }
        r = r?.next
      }
      return nil
    }
  }
}
