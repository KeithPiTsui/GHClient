import UIKit

private func swizzle(_ view: UIView.Type) {

  [(#selector(view.traitCollectionDidChange(_:)), #selector(view.ksr_traitCollectionDidChange(_:)))]
    .forEach { original, swizzled in

      let originalMethod = class_getInstanceMethod(view, original)
      let swizzledMethod = class_getInstanceMethod(view, swizzled)

      let didAddViewDidLoadMethod = class_addMethod(view,
                                                    original,
                                                    method_getImplementation(swizzledMethod),
                                                    method_getTypeEncoding(swizzledMethod))

      if didAddViewDidLoadMethod {
        class_replaceMethod(view,
                            swizzled,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod))
      } else {
        method_exchangeImplementations(originalMethod, swizzledMethod)
      }
  }
}

extension UIView {
  open override class func initialize() {
    // make sure this isn't a subclass
    guard self === UIView.self else { return }

    swizzle(self)
  }

  open override func awakeFromNib() {
    super.awakeFromNib()
    self.bindViewModel()
  }

  open func bindStyles() {
  }

  open func bindViewModel() {
  }

  public static var defaultReusableId: String {
    return self.description()
      .components(separatedBy: ".")
      .dropFirst()
      .joined(separator: ".")
  }

  internal func ksr_traitCollectionDidChange(_ previousTraitCollection: UITraitCollection) {
    self.ksr_traitCollectionDidChange(previousTraitCollection)
    self.bindStyles()
  }
}


extension UIView {
  internal var tableView: UITableView? {
   return UIView.ancestorView(of: self)
  }

  internal var collectionView: UICollectionView? {
    return UIView.ancestorView(of: self)
  }

  internal var tableViewCell: UITableViewCell? {
    return UIView.ancestorView(of: self)
  }

  internal var collectionViewCell: UICollectionViewCell? {
    return UIView.ancestorView(of: self)
  }

  internal static func ancestorView<ViewType: UIView>(of view: UIView) -> ViewType? {
    var par: UIView? = view
    while par != nil || (par is UIWindow) == false {
      if let tv = par as? ViewType {
        return tv
      }
      par = par?.superview
    }
    return nil
  }
}




