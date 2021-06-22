//
//  FetchResultsList.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/14.
//

import SwiftUI

struct FetchResultsList: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    var fetchRequest: FetchRequest<BookInfo>
    @Binding var isSearchResults: Bool
    @State var selectedItem: BookInfo?
    let fillSelectedList: Bool
    @State var selectedSet: Set<BookInfo>?
    
    let bookInfoDetailDismissed = NotificationCenter.default.publisher(for: .bookInfoDetailDismissed)
    let bookInfoSearched = NotificationCenter.default.publisher(for: .bookInfoSearched)
    
    init(searchText: String = "", sortDescriptors: [NSSortDescriptor], isSearchResults: Binding<Bool>) {
        if searchText.isEmpty {
            fetchRequest = FetchRequest(entity: BookInfo.entity(), sortDescriptors: sortDescriptors, animation: .default)
        } else {
            let formattedSearchText = searchText.collationStringIfAvailable()
            let predicate = NSPredicate(
                format: "(%K CONTAINS[cd] %@) OR (%K CONTAINS[cd] %@)",
                #keyPath(BookInfo.fullText), formattedSearchText, #keyPath(BookInfo.userNoteCollation), formattedSearchText)
            fetchRequest = FetchRequest(entity: BookInfo.entity(), sortDescriptors: sortDescriptors, predicate: predicate, animation: .default)
        }
        _isSearchResults = isSearchResults
        fillSelectedList = UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        ForEach(fetchRequest.wrappedValue) { item in
            Button(action: {
                NotificationCenter.default.post(name: .bookInfoSelected, object: item)
                selectedItem = item
            }, label: {
                BookView(bookInfo: item)
            })
            .foregroundColor(.primary)
            .listRowBackground((item == selectedItem && fillSelectedList) ? Color.systemFill : Color.systemBackground)
        }
        .onDelete(perform: deleteItems)
        .onReceive(bookInfoSearched, perform: { output in
            guard let item = output.object as? BookInfo else { return }
            selectedItem = item
        })
        
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { fetchRequest.wrappedValue[$0] }.forEach(SpotlightManager.removeItemFromIndex(item:))
            offsets.map { fetchRequest.wrappedValue[$0] }.forEach(viewContext.delete)
            offsets.map { fetchRequest.wrappedValue[$0] }.forEach{ NotificationCenter.default.post(name: .itemDeleted, object: $0.objectID) }
            do {
                try viewContext.save()                
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

//struct FetchResultsList_Previews: PreviewProvider {
//    static var previews: some View {
//        FetchResultsList()
//    }
//}
