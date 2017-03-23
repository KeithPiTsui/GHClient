//
//  UIViewLadder.swift
//  GHClient
//
//  Created by Pi on 24/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

extension UIView {
  public var tableView: UITableView? {
    return UIView.firstAncestor(UITableView.self)(self)
  }

  public var collectionView: UICollectionView? {
    return UIView.firstAncestor(UICollectionView.self)(self)
  }

  public var tableViewCell: UITableViewCell? {
    return UIView.firstAncestor(UITableViewCell.self)(self)
  }

  public var collectionViewCell: UICollectionViewCell? {
    return UIView.firstAncestor(UICollectionViewCell.self)(self)
  }

  public static func firstAncestor<V: UIView>(_: V.Type) -> (UIView) -> V? {
    return { view in
      var tv: UIView? = view
      while tv != nil && (tv is UIWindow) == false {
        if tv is V { return tv as? V }
        tv = tv?.superview
      }
      return nil
    }
  }

  public static func firstDescedant<V: UIView>(_: V.Type) -> (UIView) -> V? {
    return { view in
      var svs: [UIView] = [view]
      while svs.isEmpty == false  {
        for sv in svs {
          if sv is V { return sv as? V }
        }
        svs = svs.flatMap{$0.subviews}
      }
      return nil
    }
  }
}
