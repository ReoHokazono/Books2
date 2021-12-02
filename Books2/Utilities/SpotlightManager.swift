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
        guard let bookInfoId = item.bookInfoId else { return }
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
                return [bookInfoId] + contributorNames
            } else {
                return [bookInfoId]
            }
        }()
        let searchableItem = CSSearchableItem(uniqueIdentifier: bookInfoId, domainIdentifier: bookInfoDomainIdentifier, attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([searchableItem]) { (error) in
            guard let error = error else { return }
            fatalError("error: \(error.localizedDescription)")
        }
    }
    
    class func removeItemFromIndex(item: BookInfoSpotlightSearchable) {
        guard let bookInfoId = item.bookInfoId else { return }
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [bookInfoId]) { (error) in
            guard let error = error else { return }
            fatalError("error: \(error.localizedDescription)")
        }
    }
    
    class func removeItemFromIndex(bookInfoId: String) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [bookInfoId]) { (error) in
            guard let error = error else { return }
            fatalError("error: \(error.localizedDescription)")
        }
    }

}
