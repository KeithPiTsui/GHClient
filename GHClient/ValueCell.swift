/// A type that represents a cell that can be reused and configured with a value.

public protocol ValueSetableCell: class {
  var section: Int { get set }
  var row: Int { get set }
  weak var dataSource: ValueCellDataSource? {get set}
}

public protocol ValueCell: ValueSetableCell {
  associatedtype Value
  static var defaultReusableId: String { get }
  func configureWith(value: Value)
}
