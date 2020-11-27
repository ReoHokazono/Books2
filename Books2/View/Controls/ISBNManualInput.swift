//
//  ISBNManualInput.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/06.
//

import SwiftUI
import Combine

class BookLoader: ObservableObject {
    @Published var record: DownloadedRecord?
    @Published var errorMessage: String?
    func download(isbn: String) {
        OpenBDAPI.downloadRecord(isbn) {
            [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let record):
                DispatchQueue.main.async {
                    self.record = record
                    self.errorMessage = nil
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.record = nil
                }
            }
        }
    }
}

struct ISBNManualInput: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BookInfo.addedDate, ascending: false)],
        animation: .default)
    private var items: FetchedResults<BookInfo>
    @Binding var presentedSheet: ContentView.ModalPresentedSheet?
    let formatter = ISBNFormatter()
    @State var isbn = ""
    @State var loadedIsbnCode = ""
    @ObservedObject var bookLoader = BookLoader()
    @State var isTextFieldFirstResponder = false
    @State var isExistItem = false
    
    init(presentedSheet: Binding<ContentView.ModalPresentedSheet?>) {
        self._presentedSheet = presentedSheet
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("ISBN").padding(.top, 30)) {
                    ISBNTextField(text: $isbn, isFirstResponder: isTextFieldFirstResponder)
                        .font(.system(.body, design: .monospaced))
                        .onReceive(Just(isbn), perform: { input in
                            isbn = ISBNFormatter().string(isbn)
                            if let isbnCode = ISBNFormatter().code(isbn),
                               isbnCode != loadedIsbnCode{
                                loadedIsbnCode = isbnCode
                                bookLoader.download(isbn: isbnCode)
                                isExistItem = !items.filter({ $0.isbn == isbnCode }).isEmpty
                            }
                        })
                        .onAppear(perform: {
                            isTextFieldFirstResponder = true
                        })
                }
                
                Section(header: Text("プレビュー")) {
                    
                    if isExistItem {
                        Text("追加済みです")
                    } else {
                        if let record = bookLoader.record {
                            BookView(bookInfo: record)
                        }
                        
                        if let meassage = bookLoader.errorMessage {
                            Text(meassage)
                        }
                        
                        if bookLoader.record == nil && bookLoader.errorMessage == nil {
                            Spacer()
                        }
                    }
                    
                }
            }
            .navigationTitle("手動で入力")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("キャンセル", action: {
                presentedSheet = nil
            }), trailing: Button("追加", action: {
                if let record = bookLoader.record {
                    saveBookInfo(bookInfo: record.bookInfo(context: viewContext))
                    presentedSheet = nil
                }
            }).disabled(bookLoader.record == nil))
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

struct IsbnManualInput_Previews: PreviewProvider {
    static var previews: some View {
        ISBNManualInput(presentedSheet: .constant(.isbnManualInput))
    }
}
