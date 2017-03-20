//
//  LoginViewController.swift
//  GHClient
//
//  Created by Pi on 28/02/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import Prelude
import Prelude_UIKit
import ReactiveSwift
import ReactiveCocoa
import Result
import GHAPI

internal final class LoginViewController: UIViewController {

  fileprivate let viewModel: LoginViewModelType = LoginViewModel()


  @IBOutlet weak var NotificationPushSwitch: UISwitch!
  @IBOutlet weak var pushTokenTF: UITextField!
  @IBOutlet weak var authTokenTF: UITextField!
  @IBOutlet weak var passwordTF: UITextField!
  @IBOutlet weak var usernameTF: UITextField!
  @IBOutlet weak var saveAccountBtn: UIButton!
  @IBOutlet weak var removeAccountBtn: UIButton!

  @IBAction func tapOnCancelBarBtn(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  @IBAction func tapOnView(_ sender: UITapGestureRecognizer) { firstResponderTextField?.resignFirstResponder() }

  internal static func instantiate() -> LoginViewController {
    return Storyboard.Login.instantiate(LoginViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.bindUIAction()
    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardDidShow(_:)),
                                           name: NSNotification.Name.UIKeyboardWillShow,
                                           object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardWillHide(_:)),
                                           name: NSNotification.Name.UIKeyboardWillHide,
                                           object: nil)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    NotificationCenter.default.removeObserver(self)
  }

  private func bindUIAction() {
    self.usernameTF.reactive.continuousTextValues.observeValues{ [weak self] in
      guard let newName = $0 else { return }
      self?.viewModel.inputs.usernameEdit(newName)
    }

    self.passwordTF.reactive.continuousTextValues.observeValues{ [weak self] in
      guard let newPassword = $0 else { return }
      self?.viewModel.inputs.passwordEdit(newPassword)
    }

    self.authTokenTF.reactive.continuousTextValues.observeValues{ [weak self] in
      guard let newToken = $0 else { return }
      self?.viewModel.inputs.authTokenEdit(newToken)
    }

    self.pushTokenTF.reactive.continuousTextValues.observeValues{ [weak self] in
      guard let newToken = $0 else { return }
      self?.viewModel.inputs.pushTokenEdit(newToken)
    }

    self.saveAccountBtn.reactive.controlEvents(.touchUpInside).observeValues { [weak self] _ in
      self?.firstResponderTextField?.resignFirstResponder()
      guard let username = self?.usernameTF.text else { return }
      let password = self?.passwordTF.text
      let authToken = self?.authTokenTF.text
      let pushToken = self?.pushTokenTF.text
      let acc = Account(username: username, password: password, accessToken: authToken, pushToken: pushToken)
      self?.viewModel.inputs.tappedSaveAccount(acc)
    }

    self.removeAccountBtn.reactive.controlEvents(.touchUpInside).observeValues{ [weak self] _ in
      self?.firstResponderTextField?.resignFirstResponder()
      self?.viewModel.inputs.tappedRemoveAccount()
    }
  }

  internal override func bindStyles() {
    super.bindStyles()
    _ = self.navigationItem |> UINavigationItem.lens.title %~ {_ in "Login"}
    _ = self.removeAccountBtn |> UIButton.lens.titleColor(forState: .disabled) %~ {_ in UIColor.lightGray}
    _ = self.saveAccountBtn |> UIButton.lens.titleColor(forState: .disabled) %~ {_ in UIColor.lightGray}
  }

  /// Hanlding view model output signals
  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.saveAccountButtonEnable.observeForUI().observeValues{ [weak self] in
      self?.saveAccountBtn.isEnabled = $0
    }

    self.viewModel.outputs.removeAccountButtonEnable.observeForUI().observeValues{ [weak self] in
      self?.removeAccountBtn.isEnabled = $0
    }

    self.viewModel.outputs.account.skipNil().observeForUI().observeValues{ [weak self] in
      self?.usernameTF.text = $0.username
      self?.passwordTF.text = $0.password
      self?.authTokenTF.text = $0.accessToken
      self?.pushTokenTF.text = $0.pushToken
    }

    self.viewModel.outputs.accountSaved.observeValues { [weak self] in
      self?.dismiss(animated: true, completion: nil)
    }
  }
}

extension LoginViewController {
  fileprivate var firstResponderTextField: UITextField? {
    if usernameTF.isFirstResponder { return usernameTF }
    else if passwordTF.isFirstResponder { return passwordTF }
    else if authTokenTF.isFirstResponder { return authTokenTF }
    else if pushTokenTF.isFirstResponder { return pushTokenTF }
    else { return nil }
  }

  internal func keyboardDidShow(_ notification: Notification){
    guard let fr = firstResponderTextField, fr === authTokenTF || fr === pushTokenTF  else { return }
    guard let info = notification.userInfo else { return }
    guard let kbSizeValue = info[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
    let kbSize = kbSizeValue.cgRectValue.size
    var rect = view.frame
    rect.origin.y = -kbSize.height
    UIView.animate(withDuration: 0.3) { [weak self] in
      self?.view.frame = rect
    }
  }

  internal func KeyboardWillHide(_ notification: Notification){
    guard view.frame.origin.y < 0 else { return }
    var rect = view.frame
    rect.origin.y = 0
    UIView.animate(withDuration: 0.6) {
      self.view.frame = rect
      self.view.layoutIfNeeded()
    }
  }
}

extension LoginViewController: UITextFieldDelegate {
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    // Try to find next responder
    if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
      nextField.becomeFirstResponder()
    } else {
      // Not found, so remove keyboard.
      textField.resignFirstResponder()
    }
    // Do not add a line break
    return false
  }
}




























