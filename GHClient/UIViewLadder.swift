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
    return UIView.first(UITableView.self)(self)
  }

  public var collectionView: UICollectionView? {
    return UIView.first(UICollectionView.self)(self)
  }

  public var tableViewCell: UITableViewCell? {
    return UIView.first(UITableViewCell.self)(self)
  }

  public var collectionViewCell: UICollectionViewCell? {
    return UIView.first(UICollectionViewCell.self)(self)
  }

  public static func first<V: UIView>(_: V.Type) -> (UIView) -> V? {
    return { view in
      var tv: UIView? = view
      while tv != nil && (tv is UIWindow) == false {
        if tv is V { return tv as? V }
        tv = tv?.superview
      }
      return nil
    }
  }
}
