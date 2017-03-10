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
        let sections = self.numberOfSections
        for sec in 0 ..< sections {
            let items = self.numberOfItems(inSection: sec)
            for item in 0 ..< items {
                let selectedIndexPath = IndexPath(item: item, section: sec)
                self.deselectItem(at: selectedIndexPath, animated: false)
            }
        }
    }
    
    internal func selectItems(by indexPaths: [IndexPath]) {
        indexPaths.forEach { (indexPath) in
            self.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
    }
}




























