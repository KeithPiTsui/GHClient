//
//  GHClientTests.swift
//  GHClientTests
//
//  Created by Pi on 28/02/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import XCTest
@testable import GHClient

class GHClientTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }


  func testAtUserChord() {
    let str = "asdfi weralwefj asdowen @xxfkeit123h asdfwe 123"
    let gt = Guitar(chord: .atUser)
    let ranges = gt.evaluate(string: str)
    let substrs = ranges.map(str.substring(with:)).map{$0.trim()}
    print("ranges: \(ranges)")
    print("substrs: \(substrs)")
    XCTAssert(ranges.count > 0)
    XCTAssert(substrs.count > 0)
    XCTAssertEqual(substrs, ["@xxfkeit123h"])
  }

  func testMarkup() {
    let cat = FileTypeCategorizer.fileTypeCategory(of: "xx.md")
    XCTAssertEqual(cat, .markup)
  }

  func testSourceCode() {
    let cat = FileTypeCategorizer.fileTypeCategory(of: "xxx.swift")
    XCTAssertEqual(cat, .sourceCode)
  }


}
