//
//  URLSessionNetwork.swift
//  UnsplashApp
//
//  Created by Sébastien Gousseau on 26/06/2019.
//  Copyright © 2019 Sébastien Gousseau. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt

typealias DefaultNetworkService = URLSessionNetwork

class URLSessionNetwork: NetworkService {
    
    var session: URLSession
    var sessionCfg: URLSessionConfiguration
    
    private var _currentTask: URLSessionDataTask?
    
    init() {
        sessionCfg = URLSessionConfiguration.default
        sessionCfg.timeoutIntervalForRequest = 10.0
        session = URLSession(configuration: sessionCfg)
    }
    
    func data(route: String, callback: ((Result<Data, Error>) -> Void)?) {
        //print(route)
        
        if let url = route.toURL() {
            let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
                if let e = error {
                    callback?(Result.failure(e))
                }else {
                    if let r = response as? HTTPURLResponse {
                        if 200 ... 299 ~= r.statusCode {
                            if let data = data {
                                callback?(Result.success(data))
                            } else {
                                callback?(Result.failure(NetworkError.noData(url: route)))
                            }
                        }else {
                            callback?(Result.failure(NetworkError.invalidStatusCode(status: r.statusCode)))
                        }
                    }else {
                        callback?(Result.failure(NetworkError.invalidResponse(url: route)))
                    }
                }
            })
            
            task.resume()
            
        }else {
            callback?(Result.failure(NetworkError.badUrl(url: route)))
        }
    }
    
    func get<T>(_ type: T.Type, route: String, callback: ((Result<T, Error>) -> Void)?) where T: Decodable {
        print(route)
        
        data(route: route) { (result) in
            switch result {
            case .success(let data):
                do {
                    let model = try JSONDecoder().decode(type, from: data)
                    callback?(Result.success(model))
                } catch {
                    print(error)
                    callback?(Result.failure(NetworkError.serialization(error: error)))
                }
            case .failure(let error):
                callback?(Result.failure(error))
            }
        }
    }
}

extension URLSessionNetwork: ReactiveCompatible {}

extension Reactive where Base: URLSessionNetwork {
    func data(route: String) -> Observable<Data> {
        return Observable.deferred({ () -> Observable<Data> in
            return Observable.create({ (observer) -> Disposable in
                
                self.base.data(route: route) { (result) in
                    switch result {
                    case .success(let data):
                        observer.onNext(data)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
                
                return Disposables.create()
            })
        })
        .map(Optional.init)
        .retryOnBecomesReachable(nil, reachabilityService: DefaultReachabilityService.shared)
        .unwrap()
    }
    
    func get<T>(_ type: T.Type, route: String) -> Observable<T> where T: Decodable {
        return Observable.deferred({ () -> Observable<T> in
            return Observable.create({ (observer) -> Disposable in
                
                self.base.get(type, route: route) { (result) in
                    switch result {
                    case .success(let model):
                        observer.onNext(model)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
                
                return Disposables.create()
            })
        })
        .map(Optional.init)
        .retryOnBecomesReachable(nil, reachabilityService: DefaultReachabilityService.shared)
        .unwrap()
    }
}
