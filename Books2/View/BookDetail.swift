//
//  BookDetail.swift
//  books
//
//  Created by 外園玲央 on 2020/04/20.
//  Copyright © 2020 外園玲央. All rights reserved.
//

import SwiftUI
import SwiftUIX
import CoreData
import CoreSpotlight

struct BookDetail: View {
    @AppStorage(wrappedValue: true, UserDefaultKey.displayImages)
    var displayImages: Bool
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @State var bookInfo:FetchedResults<BookInfo>.Element
    @State var isUserNoteEditing = false
    @State var isDeletedItem = false {
        didSet {
            if isDeletedItem {
                presentationMode.dismiss()
            }
        }
    }
    let itemDeleted = NotificationCenter.default.publisher(for: .itemDeleted)
    
    fileprivate func SectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.body)
            .fontWeight(.bold)
            .padding(.top, 15)
            .padding(.bottom, 5)
    }
    
    var body: some View {
        if isDeletedItem {
            EmptyView()
        } else {
            List {
                HStack {
                    if displayImages {
                        URLImage(imageLoader: ImageLoader(url: bookInfo.resourceLink))
                            .frame(width: 130, height: 130, alignment: .center)
                            .padding(.top, 20)
                    }
                    VStack(alignment: .leading) {
                        Text(bookInfo.title ?? "")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .longPressCopy(bookInfo.title ?? "")
                            .padding(.bottom, 0.5)
                        if bookInfo.subtitle != nil {
                            Text(bookInfo.subtitle!)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .longPressCopy(bookInfo.subtitle!)
                                .padding(.bottom, 0.5)
                        }
                        
                        ForEach(bookInfo.contributorNames ?? [], id: \.self) { name in
                            Text(name)
                                .font(.body)
                                .longPressCopy(name)
                        }
                    }
                }
                .padding([.top, .bottom], 20)
                
                VStack(alignment: .leading) {
                    HStack {
                        SectionHeader("メモ")
                        Spacer()
                        
                        Button(action: {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }, label: {
                            Text("完了")
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                        })
                        .hidden(!isUserNoteEditing)
                        .buttonStyle(PlainButtonStyle())
                    }
                   
                    
                    TextView("", text: $bookInfo.userNote) { _ in
                        self.isUserNoteEditing = true
                    } onCommit: {
                        self.isUserNoteEditing = false
                        self.saveUserNote()
                    }
                    .isScrollEnabled(false)
  
//                    .frame(minHeight: 60)
//                    .padding(.trailing, 5)
                }
                
                
                if bookInfo.bookDescription != nil {
                    VStack(alignment: .leading) {
                        SectionHeader("あらすじ")
                        Text(bookInfo.bookDescription!)
                            .font(.body)
                            .lineSpacing(3)
                            .longPressCopy(bookInfo.bookDescription!)
                            .padding(.bottom, 15)
                    }
                    
                }
                
                if bookInfo.tableOfContents != nil {
                    VStack(alignment: .leading) {
                        SectionHeader("目次")
                        Text(bookInfo.tableOfContents!)
                            .font(.body)
                            .lineSpacing(3)
                            .longPressCopy(bookInfo.tableOfContents!)
                            .padding(.bottom, 15)
                    }
                }
                
                HStack(alignment: .center) {
                    if bookInfo.extentValue != 0 {
                        Spacer()
                        VStack{
                            Text("ページ数")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(bookInfo.extentValue))
                                .font(.body)
                                .fontWeight(.semibold)
                                .longPressCopy(String(bookInfo.extentValue))
                        }
                    }
                    Spacer()
                    if bookInfo.publisher != nil {
                        VStack{
                            Text("出版")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(bookInfo.publisher!)
                                .font(.body)
                                .fontWeight(.semibold)
                                .longPressCopy(bookInfo.publisher!)
                        }
                    }
                    Spacer()
                    if bookInfo.publishedDate != nil {
                        VStack{
                            Text("発売日")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(bookInfo.publishedDate!, formatter: yearFormatter)
                                .font(.body)
                                .fontWeight(.semibold)
                                .longPressCopy(yearFormatter.string(from: bookInfo.publishedDate!))
                        }
                        Spacer()
                    }
                    
                }
                
                HStack {
                    Spacer()
                    VStack(alignment: .center) {
                        Text("ISBN")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(ISBNFormatter().string(bookInfo.isbn!))
                            .font(.system(.body, design: .monospaced))
                            .longPressCopy(bookInfo.isbn!)
                    }
                    Spacer()
                }
                
                
            }
            .listStyle(PlainListStyle())
            .navigationBarHidden(false)
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(itemDeleted, perform: { output in
                guard let changedObjectID = output.object as? NSManagedObjectID else { return }
                isDeletedItem = changedObjectID == bookInfo.objectID
            })
            .onDisappear(perform: {
                NotificationCenter.default.post(name: .bookInfoDetailDismissed, object: nil)
            })
        }
    }
    
    private func saveUserNote(){
        bookInfo.userNoteCollation = bookInfo.userNote?.collationStringIfAvailable()
        do {
            try viewContext.save()
        } catch {
            fatalError("error: \(error)")
        }
    }
}

private let yearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY"
    return formatter
}()

//struct BookDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        BookDetail()
//    }
//}
