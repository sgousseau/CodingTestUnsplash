//
//  ImageService.swift
//  UnsplashApp
//
//  Created by Sébastien Gousseau on 27/06/2019.
//  Copyright © 2019 Sébastien Gousseau. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

import Foundation

enum DownloadableImage{
    case content(image: UIImage)
    case offlinePlaceholder
}

enum ImageManagerError: Error {
    case decodeError
}

let MB = 1024 * 1024

final class ImageManager {
    
    static let shared = ImageManager()
    
    private let network = DefaultNetworkService()
    private let reachability = DefaultReachabilityService.shared
    private let operationQueue = OperationQueue()
    private let backgroundWorkScheduler: ImmediateSchedulerType
    
    private let _imageCache = NSCache<AnyObject, AnyObject>()
    private let _imageDataCache = NSCache<AnyObject, AnyObject>()
    
    let isLoading = ActivityIndicator()
    
    private init() {
        _imageDataCache.totalCostLimit = 100 * MB
        
        _imageCache.countLimit = 50
        
        operationQueue.maxConcurrentOperationCount = 2
        operationQueue.qualityOfService = QualityOfService.userInitiated
        backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
    }
    
    private func decodeImage(_ imageData: Data) -> Observable<UIImage> {
        return Observable.just(imageData)
            .observeOn(backgroundWorkScheduler)
            .map { data in
                guard let image = UIImage(data: data) else {
                    // some error
                    throw ImageManagerError.decodeError
                }
                return image.forceLazyImageDecompression()
        }
    }
    
    private func _imageFromURL(_ route: String) -> Observable<UIImage> {
        return Observable.deferred {
            let maybeImage = self._imageCache.object(forKey: route as AnyObject) as? UIImage
            
            let decodedImage: Observable<UIImage>
            
            if let image = maybeImage {
                decodedImage = Observable.just(image)
            }
            else {
                let cachedData = self._imageDataCache.object(forKey: route as AnyObject) as? Data
                
                if let cachedData = cachedData {
                    decodedImage = self.decodeImage(cachedData)
                }
                else {
                    // fetch from network
                    decodedImage = self.network.rx.data(route: route)
                        .do(onNext: { data in
                            self._imageDataCache.setObject(data as AnyObject, forKey: route as AnyObject)
                        })
                        .flatMap(self.decodeImage)
                        .trackActivity(self.isLoading)
                }
            }
            
            return decodedImage.do(onNext: { image in
                self._imageCache.setObject(image, forKey: route as AnyObject)
            })
        }
    }
    
    func imageFromURL(_ route: String) -> Observable<DownloadableImage> {
        return _imageFromURL(route)
            .map { DownloadableImage.content(image: $0) }
            .retryOnBecomesReachable(DownloadableImage.offlinePlaceholder, reachabilityService: reachability)
            .startWith(.content(image: UIImage()))
    }
}
