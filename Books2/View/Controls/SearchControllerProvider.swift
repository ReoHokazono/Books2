//
//  SearchControllerProvider.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/14.
//

import SwiftUI

class SearchControllerProvider: NSObject, ObservableObject {
    
    var searchController:UISearchController!
    @Published var searchText: String = ""
    @Published var isSearching = false
    var searchTextUpdated: (String) -> () = { _ in }
    
    
    override init() {
        super.init()
        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.delegate = self
    }
}

extension SearchControllerProvider: UISearchControllerDelegate {

    func didPresentSearchController(_ searchController: UISearchController) {
        isSearching = true
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        isSearching = false
    }
}

extension SearchControllerProvider: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            self.searchText = searchText
        }
    }
}

struct SearchControllerProviderModifier: ViewModifier {
    let searchControllerProvider: SearchControllerProvider
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ViewControllerResolver(onResolve: { (viewController) in
                    viewController.navigationItem.searchController = searchControllerProvider.searchController
                })
                .frame(width: 0, height: 0)
            )
    }
}

extension View {
    func searchBar(provider: SearchControllerProvider) -> some View {
        modifier(SearchControllerProviderModifier(searchControllerProvider: provider))
    }
}
