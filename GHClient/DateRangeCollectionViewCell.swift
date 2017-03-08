//
//  DateRangeCollectionViewCell.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result

internal typealias DateRange = (Date?, Date?)

internal final class DateRangeCollectionViewCell: UICollectionViewCell, ValueCell {
    
    @IBOutlet weak var rightDateBtn: UIButton!
    @IBOutlet weak var leftDateBtn: UIButton!
    
    fileprivate let leftDate = MutableProperty<Date?>(nil)
    fileprivate let rightDate = MutableProperty<Date?>(nil)
    
    internal var section: Int = 0
    internal var row: Int = 0
    internal weak var dataSource: ValueCellDataSource? = nil
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.rightDateBtn.reactive.title(for: .normal) <~ self.rightDate.signal.map{
            if $0 == nil { return "Date"
            } else { return $0!.string(with: "yyyy-MM-dd") }
        }
        
        self.rightDate.signal.observeForUI().observeValues { [weak self] in
            let color = $0 == nil ? UIColor.lightGray : UIColor.black
            self?.rightDateBtn.setTitleColor(color, for: .normal)
        }
        
        self.leftDateBtn.reactive.title(for: .normal) <~ self.leftDate.signal.map{
            if $0 == nil { return "Date"
            } else { return $0!.string(with: "yyyy-MM-dd")}
        }
        
        self.leftDate.signal.observeForUI().observeValues { [weak self] in
            let color = $0 == nil ? UIColor.lightGray : UIColor.black
            self?.leftDateBtn.setTitleColor(color, for: .normal)
        }
    }
    
    override func bindStyles() {
        super.bindStyles()
    }
    
    internal func configureWith(value: DateRange) {
        self.leftDate.value = value.0
        self.rightDate.value = value.1
    }
    
    internal func set(date: Date, by dateBtn: UIButton) {
        if dateBtn === self.rightDateBtn {
            self.rightDate.value = date
        }
        if dateBtn === self.leftDateBtn {
            self.leftDate.value = date
        }
        self.saveDates()
    }
    
    fileprivate func saveDates() {
        let dates = (self.leftDate.value, self.rightDate.value)
        self.dataSource?.set(value: dates,
                             cellClass: DateRangeCollectionViewCell.self,
                             inSection: self.section,
                             row: self.row)
    }
}



















