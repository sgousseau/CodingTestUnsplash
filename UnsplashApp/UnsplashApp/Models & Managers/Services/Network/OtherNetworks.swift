//
//  OtherNetworks.swift
//  UnsplashApp
//
//  Created by Sébastien Gousseau on 26/06/2019.
//  Copyright © 2019 Sébastien Gousseau. All rights reserved.
//

import Foundation

class AlamofireNetwork: NetworkService {
    func data(route: String, callback: ((Result<Data, Error>) -> Void)?) {
        callback?(Result.failure(ServiceError.notImplemented(service: "Alamofire")))
    }
    
    func get<T>(_ type: T.Type, route: String, callback: ((Result<T, Error>) -> Void)?) where T: Decodable {
        callback?(Result.failure(ServiceError.notImplemented(service: "Alamofire")))
    }
}

class JustNetwork: NetworkService {
    func data(route: String, callback: ((Result<Data, Error>) -> Void)?) {
        callback?(Result.failure(ServiceError.notImplemented(service: "JustNetwork")))
    }
    
    func get<T>(_ type: T.Type, route: String, callback: ((Result<T, Error>) -> Void)?) where T: Decodable {
        callback?(Result.failure(ServiceError.notImplemented(service: "JustNetwork")))
    }
}

class AnyOtherNetwork: NetworkService {
    func data(route: String, callback: ((Result<Data, Error>) -> Void)?) {
        callback?(Result.failure(ServiceError.notImplemented(service: "AnyOtherNetwork")))
    }
    
    func get<T>(_ type: T.Type, route: String, callback: ((Result<T, Error>) -> Void)?) where T: Decodable {
        callback?(Result.failure(ServiceError.notImplemented(service: "AnyOtherNetwork")))
    }
}
