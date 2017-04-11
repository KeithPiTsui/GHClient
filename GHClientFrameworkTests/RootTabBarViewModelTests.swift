//
//  RootTabBarViewModelTests.swift
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

fileprivate func eraseAll(_ all: Any) -> Int { return 1 }

final class RootTabBarViewModelTests: XCTestCase {
  fileprivate let vm: RootTabBarViewModelType = RootTabBarViewModel()

  fileprivate let userAuthentication = TestObserver<Int, NoError>()
  fileprivate let noAccountGotoGuestMode = TestObserver<Int, NoError>()
  fileprivate let authenticationFailedThenPromoteError = TestObserver<Int, NoError>()
  fileprivate let userChooseToLoginFromAlert = TestObserver<Int, NoError> ()

  fileprivate let authenticationSucceedToAccountMode = TestObserver<Int, NoError>()

  fileprivate let userChooseGuestModeFromAlert = TestObserver<Int, NoError> ()
  fileprivate let userLoginSucceedToAccountMode = TestObserver<Int, NoError> ()
  fileprivate let userChoosGuestModeFromLogin = TestObserver<Int, NoError> ()

  fileprivate let userSelectedTabIndex = TestObserver<Int, NoError>()
  fileprivate let userWantVCToBeScrolledToTop = TestObserver<Int, NoError>()

  override func setUp() {
    super.setUp()

    AppEnvironment.initialize()

    self.vm.outputs.showUserAuthenticationFailedError
      .map(eraseAll)
      .observe(self.authenticationFailedThenPromoteError.observer)

    self.vm.outputs.showUserLoginView
      .map(eraseAll)
      .observe(self.userChooseToLoginFromAlert.observer)

    let vcCount = self.vm.outputs.setViewControllers.map{$0.0.count}
    let authVC = vcCount.filter{$0 == 1}
    let accountMode = vcCount.filter{$0 == 4}
    let guestMode = vcCount.filter{$0 == 3}

    authVC
      .map(eraseAll)
      .observe(self.userAuthentication.observer)

    Signal.combineLatest(authVC, guestMode)
      .map(eraseAll)
      .observe(self.noAccountGotoGuestMode.observer)

    Signal.combineLatest(authVC, accountMode)
      .map(eraseAll)
      .observe(self.authenticationSucceedToAccountMode.observer)

    Signal.combineLatest(authVC,
                         self.vm.outputs.showUserAuthenticationFailedError,
                         guestMode)
      .map(eraseAll)
      .observe(self.userChooseGuestModeFromAlert.observer)

    Signal.combineLatest(authVC,
                         self.vm.outputs.showUserAuthenticationFailedError,
                         self.vm.outputs.showUserLoginView,
                         guestMode)
      .map(eraseAll)
      .observe(self.userChoosGuestModeFromLogin.observer)

    Signal.combineLatest(authVC,
                         self.vm.outputs.showUserAuthenticationFailedError,
                         self.vm.outputs.showUserLoginView,
                         accountMode)
      .map(eraseAll)
      .observe(self.userLoginSucceedToAccountMode.observer)


    self.vm.outputs.selectedIndex.observe(self.userSelectedTabIndex.observer)
    self.vm.outputs.scrollToTop.map(eraseAll).observe(self.userWantVCToBeScrolledToTop.observer)

  }


  func testPathOne() {
    self.vm.inputs.viewDidLoad()
    self.userAuthentication.assertValues([1], "should execute authentication right after view did load")
    self.vm.inputs.appRunOnGuestMode()
    self.noAccountGotoGuestMode.assertValues([1], "should go to guest mode directly")
  }

  func testPathTwo() {
    self.vm.inputs.viewDidLoad()
    self.userAuthentication.assertValues([1], "should execute authentication right after view did load")
    self.vm.inputs.userSessionStarted()
    self.authenticationSucceedToAccountMode.assertValues([1], "should go to account mode directly")
  }

  func testPathThree() {
    self.vm.inputs.viewDidLoad()
    self.userAuthentication.assertValues([1], "should execute authentication right after view did load")
    self.vm.inputs.userAuthenticationFailed(with: .unknownError)
    self.authenticationFailedThenPromoteError.assertValues([1], "should promote alert after recieve an authentication error")
    self.vm.inputs.shouldEnterGuestMode()
    self.userChooseGuestModeFromAlert.assertValues([1], "should go to guest mode after user choose to from alert")
  }

  func testPathFour() {
    self.vm.inputs.viewDidLoad()
    self.userAuthentication.assertValues([1], "should execute authentication right after view did load")
    self.vm.inputs.userAuthenticationFailed(with: .unknownError)
    self.authenticationFailedThenPromoteError.assertValues([1], "should promote alert after recieve an authentication error")
    self.vm.inputs.shouldProvideLoginView()
    self.userChooseToLoginFromAlert.assertValues([1], "should go to login view for user from alert")
    self.vm.inputs.appRunOnGuestMode()
    self.userChoosGuestModeFromLogin.assertValues([1], "should enter guest mode from login view")
  }

  func testPathFive() {
    self.vm.inputs.viewDidLoad()
    self.userAuthentication.assertValues([1], "should execute authentication right after view did load")
    self.vm.inputs.userAuthenticationFailed(with: .unknownError)
    self.authenticationFailedThenPromoteError.assertValues([1], "should promote alert after recieve an authentication error")
    self.vm.inputs.shouldProvideLoginView()
    self.userChooseToLoginFromAlert.assertValues([1], "should go to login view for user from alert")
    self.vm.inputs.userSessionStarted()
    self.userLoginSucceedToAccountMode.assertValues([1], "should enter account mode for user from login")
  }

  func testSelectedIndex () {
    self.testPathFive()
    self.vm.inputs.didSelectIndex(0)
    self.userSelectedTabIndex.assertValues([0], "should equal input selected index")
    self.vm.inputs.didSelectIndex(0)
    self.userSelectedTabIndex.assertValues([0, 0], "should equal input selected index")
    self.userWantVCToBeScrolledToTop.assertValues([1], "should scroll to top after double tap")
  }



}
