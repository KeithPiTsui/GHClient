//
//  FileTypeCategorizer.swift
//  GHClient
//
//  Created by Pi on 21/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import Foundation
import MobileCoreServices

fileprivate class A {}
public enum FileTypeCategorizer {
  public enum FileTypeCategory {
    case image
    case audio
    case video
    case markup
    case sourceCode
    case documment
    case others
  }
  public static let imageCategoryExtensions
    = ["tiff","tif","jpg","jpeg","gif","png","bmp","bmpf","ico","cur","xbm","cr2","arw","nef","crw","raf","dng","mos",
       "kdc","dcr","orf","srw","3fr","mef","arw","x3f","srw","pef","rw2","raw"]

  public static let videoCategoryExtension
    = ["mkv","asf","vob","m2ts"]

  public static let sourceCodeCategoryExtension: [String] = {
    let bundle = Bundle(for: A.self)
    guard
      let filePath = bundle.path(
        forResource: "SouceCodeFileExtension",
        ofType: "txt",
        inDirectory: nil)
      else { return [] }
    let fileURL = URL(fileURLWithPath: filePath)
    guard let content = try? String(contentsOf: fileURL) else { return [] }
    let str = content
      .replacingOccurrences(of: " ", with: "")
      .replacingOccurrences(of: "\n", with: ",")
    let elements = str.components(separatedBy: ",")
    return elements
  }()

  public static let documentCategoryExtension
    = ["doc","docx","ppt","pptx","xls","xlsx","pdf","pages","numbers","key"]

  public static let markupCategoryExtension
    = ["markdown", "md", "mkdown", "mkd"]

  public static func fileTypeCategory(of fileName: String) -> FileTypeCategorizer.FileTypeCategory {
    let fileExtension = (fileName as NSString).pathExtension.lowercased()

    if imageCategoryExtensions.contains(fileExtension) {
      return .image
    }

    guard let ummanagedFileUTI
      = UTTypeCreatePreferredIdentifierForTag(
        kUTTagClassFilenameExtension,
        fileExtension as CFString, nil)
      else { return .others }
    defer { ummanagedFileUTI.release()}
    let fileUTI = ummanagedFileUTI.takeUnretainedValue()

    if
      UTTypeConformsTo(fileUTI, kUTTypeMovie)
        || videoCategoryExtension.contains(fileExtension) { return .video}
    else if
      UTTypeConformsTo(fileUTI, kUTTypeAudio) { return .audio}
    else if
      markupCategoryExtension.contains(fileExtension) { return .markup }
    else if
      sourceCodeCategoryExtension.contains(fileExtension) { return .sourceCode}
    else if
      UTTypeConformsTo(fileUTI, kUTTypeText)
        || documentCategoryExtension.contains(fileExtension){ return .documment}

    return .others
  }
}
