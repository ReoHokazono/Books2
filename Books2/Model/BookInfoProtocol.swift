//
//  BookInfoExtension.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/13.
//

import Foundation

protocol BookViewDisplayable {
    var title: String? { get set }
    var subtitle: String? { get set }
    var contributorNames: [String]? { get set }
    var resourceLink: URL? { get set }
}

protocol BookInfoSpotlightSearchable {
    var isbn: String? { get set }
    var title: String? { get set }
    var subtitle: String? { get set }
    var contributorNames: [String]? { get set }
    var bookDescription: String? { get set }
    var tableOfContents: String? { get set }
}

extension BookInfo: BookViewDisplayable, BookInfoSpotlightSearchable {}
