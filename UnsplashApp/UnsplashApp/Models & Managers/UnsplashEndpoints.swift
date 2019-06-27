//
//  UnsplashEndpoints.swift
//  UnsplashApp
//
//  Created by Sébastien Gousseau on 26/06/2019.
//  Copyright © 2019 Sébastien Gousseau. All rights reserved.
//

import Foundation

struct UnsplashEndpoints {
    
    private let base:       String
    private let key:        String
    
    let searchText:         Endpoint
    
    init(baseUrl: String = "http://api.unsplash.com",
         apiKey: String = "a76ebbad189e7f2ae725980590e4c520a525e1db029aa4cea87b44383c8a1ec4") {
        self.base = baseUrl
        self.key = apiKey
        self.searchText = Endpoint(route: String(format: "%@/search/photos?query=:query&page=:page&client_id=%@", base, key))
    }
    
    class Endpoint {
        
        //Variable pour stocker l'état initial de la route, avec l'ensemble des arguments posibblement utilisables
        private var initial: String = ""
        
        //Variable pour stocker l'état courant de la route configurée par rapport à l'état initial à l'aide des derniers arguments
        var route: String = ""
        
        init(route: String) {
            self.initial = route
            self.configuredWith(nil)
        }
        
        //Fonction permettant de configurer les paramètres optionaux de l'url
        @discardableResult
        func configuredWith(_ args: String?...) -> Self {
            self.route = initial
            
            let argsPattern = "(:\\w+)"
            let argsRgx     = try! NSRegularExpression(pattern: argsPattern, options: [])
            for (_, arg) in args.enumerated() {
                let argsMatches = argsRgx.matches(in: route, options: [], range: route.fullNSRange())
                let range = argsMatches.first!.range(at: 1)
                //Je laisse ici le force unwrap pour être certain de ne pas passer plus d'arguments que l'url ne permet, l'inverse reste possible, on peut passer moins d'arguments.
                let r = route.index(route.startIndex, offsetBy: range.location) ..<
                    route.index(route.startIndex, offsetBy: range.location+range.length)
                
                if let a = arg {
                    route.replaceSubrange(r, with: "\(a)")
                }else {
                    route.replaceSubrange(r, with: "")
                }
            }
            
            //On nettoie les arguments restants
            route = argsRgx.stringByReplacingMatches(in: route, options: [], range: route.fullNSRange(), withTemplate: "")
            
            return self
        }
    }
}
