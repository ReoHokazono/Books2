//
//  AcknowledgmentsItem.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/15.
//

import Foundation

struct AcknowledgmentsItem: Codable, Identifiable {
    var id: String {
        title
    }
    
    var title: String
    var name: String
    var link: String
    var article: String
}
