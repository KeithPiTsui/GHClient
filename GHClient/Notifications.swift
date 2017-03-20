import Foundation

public enum CurrentUserNotifications {
  public static let sessionStarted = "CurrentUserNotifications.sessionStarted"
  public static let sessionEnded = "CurrentUserNotifications.sessionEnded"
  public static let userUpdated = "CurrentUserNotifications.userUpdated"
  public static let userLoginFailed = "CurrentUserNotifications.userLoginFailed"
}

extension Notification.Name {
  public static let gh_sessionStarted = Notification.Name(rawValue: CurrentUserNotifications.sessionStarted)
  public static let gh_sessionEnded = Notification.Name(rawValue: CurrentUserNotifications.sessionEnded)
  public static let gh_userUpdated = Notification.Name(rawValue: CurrentUserNotifications.userUpdated)
  public static let gh_userLoginFailed = Notification.Name(rawValue: CurrentUserNotifications.userLoginFailed)
}


public enum NotificationKeys {
  public static let loginFailedError = "loginFailedError"
}
