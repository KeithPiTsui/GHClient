//
//  GuitarCodec.swift
//  GHClient
//
//  Created by Pi on 21/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import Foundation

public extension String {
  /// return a secret string after encode into base64
  public func base64Encoded() -> String? {
    return data(using: String.Encoding.utf8)?.base64EncodedString()
  }

  /// return a plain string after decoded from base64
  public func base64Decoded() -> String? {
    guard
      let data = Data(base64Encoded: self,
                      options: Data.Base64DecodingOptions.ignoreUnknownCharacters)
      else { return nil }
    return String(data: data, encoding: .utf8)
  }
}
