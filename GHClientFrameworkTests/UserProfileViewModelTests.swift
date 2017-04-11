//
//  UserProfileViewModelTests.swift
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

class UserProfileViewModelTests: XCTestCase {

  fileprivate let vm: UserProfileViewModelType = UserProfileViewModel()
  fileprivate let user = TestObserver<User, NoError>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.user.observe(self.user.observer)
  }


  func testExample() {
    self.vm.inputs.set(user: .template)
    self.vm.inputs.viewDidLoad()
    self.user.assertValues([.template], "one user enter")
  }

}
