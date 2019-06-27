//
//  ServiceErrors.swift
//  UnsplashApp
//
//  Created by Sébastien Gousseau on 26/06/2019.
//  Copyright © 2019 Sébastien Gousseau. All rights reserved.
//

import Foundation

enum ServiceError: Error {
    case notImplemented(service: String)
    case executionError(error: Error)
}
