//
//  ImageFetcher.swift
//  GHClient
//
//  Created by Pi on 31/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit
import Result
import ReactiveSwift
import TwitterImagePipeline

internal struct ImageFetcher {
  internal static func image(of url: URL) -> SignalProducer<UIImage, AnyError> {
    return SignalProducer{ (observer, disposable) in
      let req = ImageFetcherRequest(url: url)
      let op = AppEnvironment.current.imagePipeline.operation(with: req, context: nil, completion: { (result, error) in
        guard
          let image = result?.imageContainer.image
          else {
            observer.send(error: AnyError(error!))
            return
        }
        observer.send(value: image)
        observer.sendCompleted()
      })
      disposable += {
        op.cancel()
      }
      AppEnvironment.current.imagePipeline.fetchImage(with: op)
    }
  }
}

internal final class ImageFetcherRequest: NSObject, TIPImageFetchRequest {
  internal var imageURL: URL
  init(url: URL) {
    self.imageURL = url
  }
}










