//
//  UIViewControllerLadder.swift
//  GHClient
//
//  Created by Pi on 24/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

extension UIViewController {
  public static func first<VC: UIViewController>(_:VC.Type) -> (UIViewController) -> VC? {
    return { viewController in
      var tvc: UIViewController? = viewController
      while tvc != nil {
        if tvc is VC { return tvc as? VC }
        tvc = tvc?.parent
      }
      return nil
    }
  }
}
