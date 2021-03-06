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
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var allItems: FetchedResults<BookInfo>
        
    @StateObject var searchControllerProvider = SearchControllerProvider()
    @StateObject var sortManager = SortManager()
    @State var showScannerView = true
    @State var modalPresentedSheet: ModalPresentedSheet?
    @State var alertContent: AlertContent?
    
    #if DEBUG
    @State var isISBNListAdded = false
    #endif
    
    enum ModalPresentedSheet: String, Identifiable {
        var id: String { rawValue }
        case settings, isbnManualInput
    }
    
    enum AlertContent:String, Identifiable {
        var id: String { rawValue }
        case notFound, alredayExist
    }

    init() {
//        UITableView.appearance().contentInset.top = -20
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
                    isSearchResults: $searchControllerProvider.isSearching)
                    .environment(\.managedObjectContext, viewContext)
            }
            .navigationTitle("BookNote")
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
//                            .font(.system(size: 26, weight: .light, design: .default))
//                            .padding([.vertical, .leading])
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
            .onChange(of: scenePhase) { (newScenePhase) in
                if newScenePhase == .active {
                    UserDefaults.standard.openAppCount += 1
                    ReviewRecommender.requestReviewIfNeeded(bookInfoCount: allItems.count)
                    
                }
            }
            .alert(item: $alertContent, content: { (content) -> Alert in
                if content == .notFound {
                    return Alert(title: Text("書誌情報が見つかりませんでした"), message: Text("書誌情報データベースは、今後のアップデートで拡充する予定です"), dismissButton: .default(Text("了解")))
                } else {
                    return Alert(title: Text("すでに追加済みです"), message: nil, dismissButton: .default(Text("了解")))
                }
            })

            .onAppear(perform: {
                #if DEBUG
                if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") && !isISBNListAdded {
                    DispatchQueue(label: "test queue").async {
                        screenshotISBNList.forEach { (isbn) in
                            let semaphore = DispatchSemaphore(value: 0)
                            self.addBookInfo(isbn: isbn) {
                                semaphore.signal()
                            }
                            semaphore.wait()
                        }
                    }
                    
                    isISBNListAdded = true
                }
                #endif
            })
    }
    
    private func addBookInfo(isbn: String, completion: @escaping () -> () = {}) {
        guard allItems.filter({ $0.isbn == isbn }).isEmpty else {
            FeedbackGenerator.shared.feedback(isSuccess: false)
            alertContent = .alredayExist
            return
        }
        
        OpenBDAPI.downloadRecord(isbn) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let record):
                    FeedbackGenerator.shared.feedback(isSuccess: true)
                    withAnimation {
                        let bookInfo = record.bookInfo(context: viewContext)
                        self.saveBookInfo(bookInfo: bookInfo)
                    }
                    completion()
                case .failure(_):
                    FeedbackGenerator.shared.feedback(isSuccess: false)
                    alertContent = .notFound
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
