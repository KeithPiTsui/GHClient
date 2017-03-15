//
//  UICollectionView-Extension.swift
//  GHClient
//
//  Created by Pi on 10/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

extension UICollectionView {
  internal func clearAllSelectedItem() {
    (0 ..< self.numberOfSections)
      .forEach { (sec) in
        (0 ..< self.numberOfItems(inSection: sec))
          .forEach { (item) in
            self.deselectItem(at: IndexPath(item: item, section: sec), animated: false)
        }
    }
  }
  internal func selectItems(by indexPaths: [IndexPath]) {
    indexPaths
      .forEach {
        self.selectItem(at: $0, animated: false, scrollPosition: .centeredHorizontally)
    }
  }
}
