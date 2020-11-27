//
//  AcknowledgmentsDetail.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/15.
//

import SwiftUI

struct AcknowledgmentsDetail: View {
    
    @Environment(\.openURL) var openURL
    var item: AcknowledgmentsItem
    
    var body: some View {
        Form {
            Text(item.title)
                .font(.headline)
            Text(item.name)
                .font(.subheadline)
            Button(item.link) {
                guard let url = URL(string: item.link) else { return }
                openURL(url)
            }
            .font(.subheadline)
            Text(item.article)
                .font(.callout)
        }
    }
}

struct AcknowledgmentsDetail_Previews: PreviewProvider {
    static var previews: some View {
        AcknowledgmentsDetail(item: AcknowledgmentsData().data[0])
    }
}
