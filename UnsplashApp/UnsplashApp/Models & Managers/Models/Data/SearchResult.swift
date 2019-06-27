//
//  SearchResult.swift
//  UnsplashApp
//
//  Created by Sébastien Gousseau on 26/06/2019.
//  Copyright © 2019 Sébastien Gousseau. All rights reserved.
//

import Foundation

final class SearchResult: Codable {
    let identifier: String = UUID().uuidString
    let color: String
    let description: String?
    let alt_description: String?
    let urls: SearchResultImageUrls
    let user: SearchResultUser
}
