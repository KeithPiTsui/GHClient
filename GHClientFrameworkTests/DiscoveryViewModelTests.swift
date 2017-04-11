//
//  DiscoveryViewModelTests.swift
//  GHClient
//
//  Created by Pi on 11/04/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import GHAPI
@testable import GHClientFramework
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

final class DiscoveryViewModelTests: XCTestCase {

  fileprivate let vm: DiscoveryViewModelType = DiscoveryViewModel()
  fileprivate let trendingReposExists = TestObserver<Bool, NoError>()


  override func setUp() {
    super.setUp()

    self.vm.outputs.repositories.map{$0.isEmpty}.observe(self.trendingReposExists.observer)
  }

  func testExample() {

    self.trendingReposExists.assertValues([], "No repo before view did load")


  }


}
