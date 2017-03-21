//
//  HighlighterTests.swift
//  HighlighterTests
//
//  Created by Pi on 20/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import XCTest
@testable import Highlighter

internal final class HighlighterTests: XCTestCase {

  internal let hl = Highlightr()

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testExample() {
    let langs = hl.supportedLanguages
    print("\(langs)")

  }


}
