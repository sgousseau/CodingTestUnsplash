//
//  SearchResponse.swift
//  UnsplashApp
//
//  Created by Sébastien Gousseau on 26/06/2019.
//  Copyright © 2019 Sébastien Gousseau. All rights reserved.
//

import Foundation

final class SearchResponse: Codable {
    let total: Int
    let total_pages: Int
    var results: [SearchResult]
    
    var page: Int? = 0
    
    func merged(with previous: SearchResponse, page: Int) {
        let mergedResults = previous.results + results
        results = mergedResults
    }
}
