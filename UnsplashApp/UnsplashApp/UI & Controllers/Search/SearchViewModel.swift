//
//  SearchViewModel.swift
//  UnsplashApp
//
//  Created by Sébastien Gousseau on 26/06/2019.
//  Copyright © 2019 Sébastien Gousseau. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import Differentiator

final class SearchViewModel {
    
    private let searchManager = SearchManager()
    
    var bag: DisposeBag! = DisposeBag()
    let queryItems = PublishRelay<String>()
    let nextItems = PublishRelay<Void>()
    var items = PublishSubject<[TableViewSection]>()
    
    private var queryPage = 0
    
    deinit {
        bag = nil
    }
    
    init(searchBar: UISearchBar, tableView: UITableView) {

        //On capte le texte entré dans la searchBar et on l'injecgte dans queryItems
        searchBar.rx.text.orEmpty
            .debounce(.milliseconds(450), scheduler: MainScheduler.instance)
            .do(onNext: { _ in
                self.queryPage = 0
            })
            .bind(to: queryItems)
            .disposed(by: bag)
        
        //Dès que le signal de fin de liste arrive, on récupère le texte de la query
        let nextQueryItems = nextItems
            .withLatestFrom(searchBar.rx.text.orEmpty)
        
        //Quand une query ou qu'une nouvelle page est demandée, on télécharge les données
        let dataRequest = Observable.of(queryItems.asObservable(), nextQueryItems).merge()
            .flatMap({ self.searchManager.rx.query($0, page: self.queryPage + 1) })
            .do(onNext: { (response) in
                self.queryPage = response.page!
            })
        
        //On transforme le résultat de la réponse reçue lors d'une demande de donnée en élément de liste
        dataRequest
            .map { [TableViewSection(header: "", items: $0.results)] }
            .bind(to: items)
            .disposed(by: bag)
        
        //On associe une recherche vide avec l'envoi d'un tableau d'item vide
        queryItems.filter { $0.isEmpty }
            .map { _ in [TableViewSection]() }
            .bind(to: items)
            .disposed(by: bag)
        
        //On associe les items disponible à notre liste
        items
            .bind(to: tableView.rx.items(dataSource: tableViewConfiguration()))
            .disposed(by: bag)
        
        //On associe le téléchargement des résultats, ainsi que le téléchargement des images des cellules à isLoading
        Observable.combineLatest(ImageManager.shared.isLoading.asObservable(), searchManager.isLoading.asObservable()) { $0 || $1 }
            .observeOn(MainScheduler.instance)
            .bind(onNext: { (loadingSomething) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = loadingSomething
            })
            .disposed(by: bag)
    }
    
    func tableViewConfiguration() -> RxTableViewSectionedAnimatedDataSource<TableViewSection> {
        let datasource = RxTableViewSectionedAnimatedDataSource<TableViewSection>(configureCell: { (dataSource, tableView, indexPath, model) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.searchResultCell, for: indexPath)!
            
            cell.descriptionLabel.text = "\(model.user.username)\n\n\(model.description ?? model.alt_description ?? "")"
            cell.downloadableImage = ImageManager.shared.imageFromURL(model.urls.small ?? model.urls.thumb ?? model.urls.raw)
            
            if tableView.isLastCell(indexPath) {
                self.nextItems.accept(())
            }
            
            return cell
        })
        
        datasource.animationConfiguration = AnimationConfiguration(insertAnimation: .left, reloadAnimation: .fade, deleteAnimation: .right)
        
        return datasource
    }
}

struct TableViewSection {
    var header: String
    var items: [Item]
}

extension TableViewSection: AnimatableSectionModelType {
    typealias Item = SearchResult
    
    var identity: String {
        return header
    }
    
    init(original: TableViewSection, items: [Item]) {
        self = original
        self.items = items
    }
}

extension SearchResult: IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: Identity {
        return identifier
    }
    
    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.identity == rhs.identity
    }
}
