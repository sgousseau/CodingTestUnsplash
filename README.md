# CodingTestUnsplash

Affichage d'images proposées par l'API [Unsplash](https://unsplash.com)

## Explications

* MVVM standard avec un business layer sous forme de gestionnaire de données (SearchManager, ImageManager). Un gestionnaire de donnée utilisera un utilitaire réseau approprié. Pour cela j'ai prévu le protocole NetworkService. SearchManager et ImageManager utilisent tous deux un objet de type NetworkService, en l'occurence URLSessionNetwork.
* SearchViewController est configuré avec un UISearchController, et initialise son ViewModel en y injectant la searchBar et la tableView. Cela permet d'écrire l'ensemble des interactions sous forme de séquence à l'initialisation directement et de n'avoir aucun code dans le viewController, même si à priori ce n'est pas une faute de coder les bindings dans le controller.
* Le viewModel déclare les interactions suivantes:
  - Une entrée dans la barre de recherche déclenche le téléchargement du résultat, après l'arrêt de la saisie + quelques millisecondes.
  - Une fin de liste déclenche le téléchargement de la page suivante.
  - Une entrée nulle déclenche une assignation de résultat vide.
  - Un téléchargement/assignation de résultat déclenche la modélisation utilisable par la liste.
  - Les modèles créés sont assignés à la liste et ImageManager procède au téléchargement ainsi que la mise en cache des images, toujours de manière asynchrone.
* Dissociation de l’utilitaire réseau (NetworkService) et des endpoints constituant l’API Unsplash et les urls des images (UnsplashEndpoints, SearchResultImages).
* La classe UnsplashEndpoints permet de déclarer les API's avec un ensemble de paramètres possiblement utilisables.
* Utilisation d'un ActivityIndicator permettant de savoir lorsqu'il y a des traitements asynchrones en cours. En combinant les ActivityIndicator de SearchManager et ImageManager, on peut savoir lorsque l'on a téléchargé l'ensemble des ressources, ou lorsqu'il en reste en attente.
* Utilisation de Reachability en version Rx, permet de reprendre les téléchargements en cas de coupure puis reprise de connexion réseau.
* Utilisation de [RxSwift](https://github.com/ReactiveX/RxSwift) permettant une déclaration de séquences symbolisant les traitements asynchrones de manière séquentielle.
* Utilisation de [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources) permettant d'injecter rapidement des éléments dans une liste en prenant en compte les animations.
* Utilisation de [Differentiator](https://github.com/ReactiveX/RxSwift/tree/master/RxExample/RxDataSources/Differentiator) permettant à RxDataSources de procéder aux insertions, suppressions, déplacements des éléments d'une liste en créeant un changeset entre les nouvelles données et précédentes.

## Reste à faire et optimisations
* Tests Rx avec [RxTests](https://cocoapods.org/pods/RxTests) et [RxBlocking](https://cocoapods.org/pods/RxBlocking).
* Code coverage à 100% (Tester l'ensemble du viewModel).
* Utiliser des icons [Lottie](https://github.com/airbnb/lottie-ios)
* Utilisation de la Restauration (RestaurationId) pour démarrer encore plus rapidement l’application avec les dernières données

## Libs concrètement utilisées

* [RxSwift](https://github.com/ReactiveX/RxSwift) - Traitements asynchrones et séquentiels
* [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources) - Gestion des UITableView et UICollectionView avec animations
* [RxSwiftExt](https://github.com/RxSwiftCommunity/RxSwiftExt) - Ajout d'opérateurs pratiques
* [Differentiator](https://github.com/ReactiveX/RxSwift/tree/master/RxExample/RxDataSources/Differentiator) - Permet à RxDataSources de procéder aux insertions, et suppressions dans les listes
* [R.swift](https://github.com/mac-cain13/R.swift) - Gestion des assets
