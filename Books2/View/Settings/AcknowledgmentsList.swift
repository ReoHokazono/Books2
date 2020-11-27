//
//  AcknowledgmentsList.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/15.
//

import SwiftUI

struct AcknowledgmentsList: View {
    let data = AcknowledgmentsData().data
    var body: some View {
        Form {
            ForEach(data) { (item) in
                NavigationLink(
                    destination: AcknowledgmentsDetail(item: item),
                    label: {
                        VStack(alignment: .leading) {
                            Text(item.title)
                            Text(item.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    })
            }
        }
        .navigationBarTitle("謝辞", displayMode: .inline)
//        .navigationTitle("謝辞")
//        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AcknowledgmentsList_Previews: PreviewProvider {
    static var previews: some View {
        AcknowledgmentsList()
    }
}


