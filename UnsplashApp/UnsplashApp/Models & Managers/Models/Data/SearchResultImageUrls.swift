//
//  SearchResultImageUrls.swift
//  UnsplashApp
//
//  Created by Sébastien Gousseau on 26/06/2019.
//  Copyright © 2019 Sébastien Gousseau. All rights reserved.
//

import Foundation

final class SearchResultImageUrls: Codable {
    let raw: String
    let small: String?
    let thumb: String?
}
