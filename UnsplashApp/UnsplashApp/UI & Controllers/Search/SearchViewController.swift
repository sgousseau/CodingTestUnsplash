//
//  ViewController.swift
//  UnsplashApp
//
//  Created by Sébastien Gousseau on 26/06/2019.
//  Copyright © 2019 Sébastien Gousseau. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa

class SearchViewController: UIViewController, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: SearchViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Unsplash something"
        navigationItem.searchController = search
        self.definesPresentationContext = true
        
        //Permet d'afficher la searchBar à l'affichage initial de la vue
        navigationItem.hidesSearchBarWhenScrolling = false
        
        viewModel = SearchViewModel(searchBar: search.searchBar, tableView: tableView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Permet de remonter la searchBar lors d'un scroll
        //BUG, ne remonte pas
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    //Fonction delegate du SearchController, que je n'utilise pas car j'utilise les fonctions Rx
    func updateSearchResults(for searchController: UISearchController) {}
}

