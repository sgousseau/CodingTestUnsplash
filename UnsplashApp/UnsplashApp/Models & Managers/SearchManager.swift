//
//  SearchManager.swift
//  UnsplashApp
//
//  Created by Sébastien Gousseau on 26/06/2019.
//  Copyright © 2019 Sébastien Gousseau. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt

final class SearchManager {
    
    fileprivate let network = DefaultNetworkService()
    fileprivate let endpoints = UnsplashEndpoints()
    fileprivate var searches = [String: SearchResponse]()
    
    let isLoading = ActivityIndicator()
}

extension SearchManager: ReactiveCompatible {}

extension Reactive where Base: SearchManager {
    
    func query(_ text: String, page: Int = 0) -> Observable<SearchResponse> {
        
        //Si on a déjà enregistré les résultats de cette requête
        if let previous = self.base.searches[text] {
            //Si on demande une page au delà de la page maximum, on ne fait rien
            if previous.total_pages < page {
                return Observable.empty()
            //Sinon, si on a déjà les résultats maximum de la requête on renvoit ce résultat
            } else if previous.page! == previous.total_pages {
                return Observable.just(previous)
            }
        }
        
        //Sinon, on, on charge les nouveaux résultats, on les combine si besoin, et on les enregistre
        
        return base.network.rx.get(SearchResponse.self, route: base.endpoints.searchText.configuredWith(text, "\(page)").route)
            .do(onNext: { (response) in
                if let previous = self.base.searches[text], previous.page! < page {
                    response.merged(with: previous, page: page)
                }
                
                response.page = page
                
                self.base.searches[text] = response
            })
            .trackActivity(base.isLoading)

    }
}
