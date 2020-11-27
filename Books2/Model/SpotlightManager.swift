//
//  SpotlightManager.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/20.
//

import Foundation
import CoreSpotlight

fileprivate let bookInfoDomainIdentifier = "bookInfo"

class SpotlightManager {
    class func updateItem(item: BookInfoSpotlightSearchable) {
        guard let isbn = item.isbn else { return }
        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = {
            if let subtitle = item.subtitle {
                return item.title ?? "" + " - " + subtitle
            } else {
                return item.title ?? ""
            }
        }()
        
        attributeSet.contentDescription = {
            if let bookDescription = item.bookDescription {
                return bookDescription
            } else if let tableOfContents = item.tableOfContents {
                return tableOfContents
            }
            return nil
        }()
        
        attributeSet.keywords = {
            if let contributorNames = item.contributorNames {
                return [isbn] + contributorNames
            } else {
                return [isbn]
            }
        }()
        print("Indexing: \(isbn)")
        let searchableItem = CSSearchableItem(uniqueIdentifier: isbn, domainIdentifier: bookInfoDomainIdentifier, attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([searchableItem]) { (error) in
            guard let error = error else { return }
            fatalError("error: \(error.localizedDescription)")
        }
    }
    
    class func removeItemFromIndex(item: BookInfoSpotlightSearchable) {
        guard let isbn = item.isbn else { return }
        print("Delete Index: \(isbn)")
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [isbn]) { (error) in
            guard let error = error else { return }
            fatalError("error: \(error.localizedDescription)")
        }
    }
    
    class func removeItemFromIndex(isbn: String) {
        print("Delete Index: \(isbn)")
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [isbn]) { (error) in
            guard let error = error else { return }
            fatalError("error: \(error.localizedDescription)")
        }
    }

}
