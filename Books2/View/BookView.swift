//
//  BookView.swift
//  books
//
//  Created by 外園玲央 on 2020/04/19.
//  Copyright © 2020 外園玲央. All rights reserved.
//

import SwiftUI

struct BookView: View {
    @AppStorage(wrappedValue: true, UserDefaultKey.displayImages)
    var displayImages: Bool
    
    var bookInfo:BookViewDisplayable
    
    var body: some View {
        HStack {
            if displayImages {
                URLImage(imageLoader: ImageLoader(url: bookInfo.resourceLink))
                    .frame(width: 100, height: 100, alignment: .center)
            }
                
            VStack(alignment: .leading) {
                Text(bookInfo.title ?? "")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if bookInfo.subtitle != nil {
                    Text(bookInfo.subtitle!)
                    .font(.body)
                    .foregroundColor(.secondary)
                }
                
                ForEach(bookInfo.contributorNames ?? [], id: \.self) { name in
                    Text(name)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
        
    }
}

//struct BookView_Previews: PreviewProvider {
//    static var previews: some View {
//        BookView(bookInfo: .constant(BookInfo()))
//    }
//}
