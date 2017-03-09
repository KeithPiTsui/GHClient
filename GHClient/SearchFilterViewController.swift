//
//  SearchFilterViewController.swift
//  GHClient
//
//  Created by Pi on 07/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import GHAPI

protocol SearchFilterViewControllerDelegate: class {
    func filteredQualifiers(_ qualifiers: [SearchQualifier])
    
    func wipe(filter: SearchFilterViewController, beginAt point: CGPoint)
    func wipe(filter: SearchFilterViewController, rightForwardAt point: CGPoint)
    func wipe(filter: SearchFilterViewController, endAt point: CGPoint)

    func closeFilter()
}


internal final class SearchFilterViewController: UIViewController {

    internal static func instantiate() -> SearchFilterViewController {
        return Storyboard.SearchFilter.instantiate(SearchFilterViewController.self)
    }
    
    internal var delegate: SearchFilterViewControllerDelegate?
    
    fileprivate let viewModel = SearchFilterViewModel()
    fileprivate let repositoriesDatasource = SearchFilterRepositoriesDatasource()
    fileprivate let usersDatasource = SearchFilterUsersDatasource()

    fileprivate weak var focusedDateBtn: UIButton? = nil
    
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    
    @IBOutlet weak var datePickerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var filterOptionsCollectionView: UICollectionView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func tappedResetBtn(_ sender: UIButton) {
        
    }
    
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: nil)
        switch sender.state {
        case .began:
            self.delegate?.wipe(filter: self, beginAt: location)
        case .changed:
            self.delegate?.wipe(filter: self, rightForwardAt: location)
        case .ended, .cancelled:
            self.delegate?.wipe(filter: self, endAt: location)
        default:
            break
        }
    }
    
    @IBAction func tappedOkayBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        delegate?.filteredQualifiers(self.generateFilters())
    }
    
    
    @IBAction func tappedDateRangeBtn(_ sender: UIButton) {
        print("touch date btn")
        self.datePicker.setDate(Date(), animated: true)
        self.focusedDateBtn = sender
        UIView.animate(withDuration: 0.1){
            self.datePicker.isHidden = false
        }
        self.moveUpCollectionView(by: self.datePickerHeight.constant)
        guard let cell = self.cellContaining(view: sender) else { return }
        let rect = cell.frame
        self.filterOptionsCollectionView.scrollRectToVisible(rect, animated: true)
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        guard let dateBtn =  focusedDateBtn else { return }
        guard let cell = self.cellContaining(view: dateBtn) as? DateRangeCollectionViewCell else { return }
        cell.set(date: sender.date, by: dateBtn)
    }
    
    internal func setFilterScope(_ scope: SearchScope) {
        self.title = scope.name.uppercased() + " Search Filter"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.filterOptionsCollectionView.dataSource = self.usersDatasource
        self.filterOptionsCollectionView.allowsMultipleSelection = true
        self.filterOptionsCollectionView.allowsSelection = true
        
        let layout = self.filterOptionsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsetsMake(10,20,10,20)
        layout.headerReferenceSize = CGSize(width:0, height:40)
        layout.itemSize = CGSize(width:100, height:45)
        
        self.datePicker.maximumDate = Date()
        self.viewModel.inputs.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.inputs.viewWillAppear(animated: animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SearchFilterViewController.keyboardDidShow(_:)),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SearchFilterViewController.keyboardWillHide(_:)),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    internal func keyboardDidShow(_ notification: Notification){
        print("keyboardWillShow")
        guard let info = notification.userInfo else { return }
        guard let kbSizeValue = info[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        guard let delegate = UIApplication.shared.delegate, let window = delegate.window else { return }
        guard let win = window else { return }
        
        let kbSize = kbSizeValue.cgRectValue.size

        let leftConner = self.view.bounds.leftConner
        let absLeftConner = self.view.convert(leftConner, to: nil)
        let absHeight = win.bounds.height - absLeftConner.y
        let dy = kbSize.height - absHeight
        
        self.moveUpCollectionView(by: dy)
        guard let fr = self.firstResponder(in: self.filterOptionsCollectionView) else { return }
        guard let cell = self.cellContaining(view: fr) else { return }
        let rect = cell.frame
        self.filterOptionsCollectionView.scrollRectToVisible(rect, animated: true)
    }
    
    internal func keyboardWillHide(_ notification: Notification) {
        self.moveDownCollectionView()
    }
    
    fileprivate func moveUpCollectionView(by height: CGFloat) {
        UIView.animate(withDuration: 0.1) {
            self.bottomHeight.constant = height
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func moveDownCollectionView() {
        guard self.bottomHeight.constant != 60 else { return }
        UIView.animate(withDuration: 0.1) {
            self.bottomHeight.constant = 60
            self.view.layoutIfNeeded()
        }
    }
    
    
    override func bindStyles() {
        super.bindStyles()
        self.datePicker.backgroundColor = UIColor.white
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        self.viewModel.outputs.userTypes.observeForUI().observeValues { [weak self] in
            self?.usersDatasource.load(userTypes: $0)
            self?.filterOptionsCollectionView.reloadData()
        }
        self.viewModel.outputs.cities.observeForUI().observeValues { [weak self] in
            self?.usersDatasource.load(cities: $0)
            self?.filterOptionsCollectionView.reloadData()
        }
        self.viewModel.outputs.createdDateRange.observeForUI().observeValues {  [weak self] _ in
            self?.usersDatasource.setCreatedDateRange()
            self?.filterOptionsCollectionView.reloadData()
        }
        self.viewModel.outputs.languages.observeForUI().observeValues { [weak self] in
            self?.usersDatasource.load(languages: $0)
            self?.filterOptionsCollectionView.reloadData()
        }
        self.viewModel.outputs.reposRange.observeForUI().observeValues { [weak self] _ in
            self?.usersDatasource.setReposRange()
            self?.filterOptionsCollectionView.reloadData()
        }
        self.viewModel.outputs.searchFields.observeForUI().observeValues { [weak self] in
            self?.usersDatasource.load(searchFields: $0)
            self?.filterOptionsCollectionView.reloadData()
        }
        self.viewModel.outputs.followersRange.observeForUI().observeValues { [weak self] _ in
            self?.usersDatasource.setFollowersRange()
            self?.filterOptionsCollectionView.reloadData()
        }
        
    }
}

extension SearchFilterViewController: UICollectionViewDelegate {
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(indexPath)")
        print("\(collectionView.indexPathsForSelectedItems)")
        if let fr = self.firstResponder(in: self.filterOptionsCollectionView) {
            fr.resignFirstResponder()
        }
        self.datePicker.isHidden = true
        self.moveDownCollectionView()
        
    }
    
    internal func firstResponder(in view: UIView) -> UIView? {
        if view.isFirstResponder { return view }
        for v in view.subviews {
            if let sv = self.firstResponder(in: v) { return sv }
        }
        return nil
    }
    
    internal func cellContaining(view: UIView) -> UICollectionViewCell? {
        if let v = view as? UICollectionViewCell { return v }
        var superview = view.superview
        while superview !== self.view {
            if let v = superview as? UICollectionViewCell { return v }
            superview = superview?.superview
        }
        return nil
    }
    
    internal func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let fr = self.firstResponder(in: self.filterOptionsCollectionView) {
            fr.resignFirstResponder()
        }
        self.datePicker.isHidden = true
        self.moveDownCollectionView()
    }
    
    internal func collectionView(_ collectionView: UICollectionView,
                                 shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if self.usersDatasource.rangeSections.contains(indexPath.section) {
            return false
        }
        if self.usersDatasource.multiChoiceSection.contains(indexPath.section) {
            return true
        }
        if self.usersDatasource.singleChoiceSection.contains(indexPath.section) {
            let num = collectionView.numberOfItems(inSection: indexPath.section)
            for i in 0..<num {
                let ip = IndexPath(item: i, section: indexPath.section)
                collectionView.deselectItem(at: ip, animated: true)
            }
            return true
        }
        return false
    }
}


extension SearchFilterViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout lay: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let lay = lay as? UICollectionViewFlowLayout else {
            fatalError("collection view layout cannot cast down as UICollectionViewFlowLayout")
        }
        var sz = lay.itemSize
        if self.usersDatasource.rangeSections.contains(indexPath.section) {
            sz.width = collectionView.frame.size.width - lay.sectionInset.left - lay.sectionInset.right
        }
        return sz
    }
}


extension SearchFilterViewController {
    internal func generateFilters() -> [UserQualifier] {
        guard let selectedIndexPath = self.filterOptionsCollectionView.indexPathsForSelectedItems else { return [] }
        return self.usersDatasource.userQualifiers(with: selectedIndexPath)
    }
}




























