//
//  UIViewControllerLadder.swift
//  GHClient
//
//  Created by Pi on 24/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

extension UIViewController {
  public static func firstAncestor<VC: UIViewController>(_:VC.Type) -> (UIViewController) -> VC? {
    return { viewController in
      var tvc: UIViewController? = viewController
      while tvc != nil {
        if tvc is VC { return tvc as? VC }
        tvc = tvc?.parent
      }
      return nil
    }
  }

  public static func firstDescedant<V: UIViewController>(_: V.Type) -> (UIViewController) -> V? {
    return { viewController in
      var cvcs: [UIViewController] = [viewController]
      while cvcs.isEmpty == false  {
        for cv in cvcs {
          if cv is V { return cv as? V }
        }
        cvcs = cvcs.flatMap{$0.childViewControllers}
      }
      return nil
    }
  }
}
