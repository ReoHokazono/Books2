//
//  ContentView.swift
//  Books2
//
//  Created by 外園玲央 on 2020/10/27.
//

import SwiftUI
import CoreData
import CoreSpotlight

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var allItems: FetchedResults<BookInfo>
        
    @State var selectedBookInfoISBN:String?
    @StateObject var searchControllerProvider = SearchControllerProvider()
    @StateObject var sortManager = SortManager()
    @State var showScannerView = true
    @State var modalPresentedSheet: ModalPresentedSheet?
    enum ModalPresentedSheet: String, Identifiable {
        var id: String { rawValue }
        case settings, isbnManualInput
    }

    init() {
        UITableView.appearance().contentInset.top = -20
    }
        
    var body: some View {
            Form {
                if showScannerView {
                    ScannerView { (isbn) in
                        self.addBookInfo(isbn: isbn)
                    } manualInput: {
                        modalPresentedSheet = .isbnManualInput
                    }
                }
                
                FetchResultsList(
                    searchText: searchControllerProvider.searchText,
                    sortDescriptors: sortManager.sortDescriptors,
                    isSearchResults: $searchControllerProvider.isSearching,
                    selectedBookInfoISBN: $selectedBookInfoISBN)
                    .environment(\.managedObjectContext, viewContext)
            }
            .navigationTitle("本棚")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        modalPresentedSheet = .settings
                    }, label: {
                        Label("設定", systemImage: "slider.horizontal.3")
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("順序", selection: $sortManager.sortAscending) {
                            Text(sortManager.ascendingFirstItemTitle).tag(SortManager.SortAscending.firstItem)
                            Text(sortManager.ascendingSecondItemTitle).tag(SortManager.SortAscending.secondItem)
                        }
                        
                        Picker("項目", selection: $sortManager.sortKey) {
                            Text("追加日").tag(SortManager.SortKey.addedDate)
                            Text("タイトル").tag(SortManager.SortKey.title)
                            Text("著者名").tag(SortManager.SortKey.contributor)
                            Text("デフォルト（追加日）").tag(SortManager.SortKey.defaultSort)
                        }
                    } label: {
                        Label("並び替え",
                              systemImage:
                                sortManager.sortAscending == .firstItem && sortManager.sortKey == .defaultSort ?
                                "arrow.up.arrow.down.square" : "arrow.up.arrow.down.square.fill")
                            .font(.system(size: 26, weight: .light, design: .default))
                            .padding([.vertical, .leading])
                    }
                }
            })
            .sheet(item: $modalPresentedSheet) { (presentedSheet) in
                switch presentedSheet {
                case .settings:
                    Settings(presentedSheet: $modalPresentedSheet)
                case .isbnManualInput:
                    ISBNManualInput(presentedSheet: $modalPresentedSheet)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .onChange(of: searchControllerProvider.isSearching, perform: { isSearching in
                withAnimation {
                    showScannerView = !isSearching
                }
            })
            .searchBar(provider: searchControllerProvider)
            .onContinueUserActivity(CSSearchableItemActionType, perform: { userActivity in
                guard let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else { return }
                let sizeClass = horizontalSizeClass ?? .compact
                if selectedBookInfoISBN == nil || sizeClass == .regular{
                    selectedBookInfoISBN = identifier
                }
            })
    }
    
    private func addBookInfo(isbn: String) {
        guard allItems.filter({ $0.isbn == isbn }).isEmpty else {
            return
        }
        
        OpenBDAPI.downloadRecord(isbn) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let record):
                    withAnimation {
                        let bookInfo = record.bookInfo(context: viewContext)
                        self.saveBookInfo(bookInfo: bookInfo)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
        
    private func saveBookInfo(bookInfo: BookInfo) {
        do {
            try viewContext.save()
            SpotlightManager.updateItem(item: bookInfo)
        } catch {
            fatalError("error: \(error)")
        }
    }

}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}