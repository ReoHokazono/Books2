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
    @Binding var selectedBookInfoId: String?
    init(searchText: String = "", sortDescriptors: [NSSortDescriptor], isSearchResults: Binding<Bool>, selectedBookInfoId: Binding<String?>) {
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
        _selectedBookInfoId = selectedBookInfoId
    }
    @State var sheetItem: BookInfo?
    
    var body: some View {
        ForEach(fetchRequest.wrappedValue) { item in
            NavigationLink(
                destination: BookDetail(bookInfo: item).environment(\.managedObjectContext, viewContext),
                tag: item.bookInfoId ?? "",
                selection: $selectedBookInfoId,
                label: {
                    BookView(bookInfo: item)
                })
        }
        .onDelete(perform: deleteItems)
      
        
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
