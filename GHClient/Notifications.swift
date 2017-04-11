import Foundation

public enum CurrentUserNotifications {
  public static let sessionStarted = "CurrentUserNotifications.sessionStarted"
  public static let sessionEnded = "CurrentUserNotifications.sessionEnded"
  public static let userUpdated = "CurrentUserNotifications.userUpdated"
  public static let userLoginFailed = "CurrentUserNotifications.userLoginFailed"
  public static let appModeGuest = "CurrentUserNotifications.appModeGuest"
  public static let userAuthenticationFailed = "CurrentUserNotifications.userAuthenticationFailed"
}

extension Notification.Name {

  /// When a user logged in, or a user was authenticated
  public static let gh_sessionStarted = Notification.Name(rawValue: CurrentUserNotifications.sessionStarted)

  /// when a user which had been logged before failed to authenticate, or log out by user
  public static let gh_sessionEnded = Notification.Name(rawValue: CurrentUserNotifications.sessionEnded)

  /// when current use is replace by another new user or info of current user has been updated
  public static let gh_userUpdated = Notification.Name(rawValue: CurrentUserNotifications.userUpdated)

  /// when a user failed to log in
  public static let gh_userLoginFailed = Notification.Name(rawValue: CurrentUserNotifications.userLoginFailed)

  /// when a user chooses to use guest mode, or never login before
  public static let appRunOnGuestMode = Notification.Name(rawValue: CurrentUserNotifications.appModeGuest)

  /// when a user failed to authenticate
  public static let gh_userAuthenticationFailed = Notification.Name(rawValue: CurrentUserNotifications.userAuthenticationFailed)
}


public enum NotificationKeys {
  public static let loginFailedError = "loginFailedError"
}
