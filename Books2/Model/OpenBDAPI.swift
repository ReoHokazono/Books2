//
//  OpenBDAPI.swift
//  books
//
//  Created by 外園玲央 on 2020/04/19.
//  Copyright © 2020 外園玲央. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

struct DownloadedRecord {
    var isbn: String
    var title: String?
    var titleCollation: String?
    var subtitle: String?
    var subtitleCollation: String?
    var contributorRoles: [String]?
    var contributorNames: [String]?
    var contributorCollations: [String]?
    var bookDescription: String?
    var tableOfContents: String?
    var extentValue: Int16
    var resourceLink: URL?
    var publisher: String?
    var publishedDate: Date?
}

extension DownloadedRecord {
    func bookInfo(context: NSManagedObjectContext) -> BookInfo {
        let bookInfo = BookInfo(context: context)
        bookInfo.addedDate = Date()
        bookInfo.bookDescription = bookDescription
        bookInfo.contributorNames = contributorNames
        bookInfo.contributorRoles = contributorRoles
        bookInfo.contributorCollations = contributorCollations?.map{ $0.collationStringIfAvailable() }
        bookInfo.extentValue = extentValue
        bookInfo.isbn = isbn
        bookInfo.publishedDate = publishedDate
        bookInfo.publisher = publisher
        bookInfo.resourceLink = resourceLink
        bookInfo.subtitle = subtitle
        bookInfo.subtitleCollation = subtitleCollation?.collationStringIfAvailable()
        bookInfo.tableOfContents = tableOfContents
        bookInfo.title = title
        bookInfo.titleCollation = titleCollation?.collationStringIfAvailable()
        let fullTextItems = [isbn, title, titleCollation, subtitle, subtitleCollation, bookDescription, tableOfContents, publisher, contributorCollations?.reduceWithSpace(), contributorNames?.reduceWithSpace()]
        let fullText = fullTextItems
            .compactMap{ $0 }
            .reduceWithSpace()
            .collationStringIfAvailable()
        bookInfo.fullText = fullText
        return bookInfo
    }
}

fileprivate extension Array where Element == String {
    func reduceWithSpace() -> String{
        return reduce("") { (result, str) -> String in
            result == "" ? str : result + " " + str
        }
    }
}

extension DownloadedRecord: BookViewDisplayable {}

class OpenBDAPI {
    
    enum OpenBDAPIError: LocalizedError {
        case unknown, notFound
        var localizedDescription: String{
            switch self {
            case .notFound:
                return "書誌情報が見つかりません"
            case .unknown:
                return "書誌情報を取得できません"
            }
        }
    }
    
    private class func parseDownloadedJson(isbn:String, json:JSON) -> DownloadedRecord? {
        let contents = json[0]
        let onix = contents["onix"]
        guard let title = onix["DescriptiveDetail"]["TitleDetail"]["TitleElement"]["TitleText"]["content"].string else {
            return nil
        }
        let titleCollation = onix["DescriptiveDetail"]["TitleDetail"]["TitleElement"]["TitleText"]["collationkey"].string ?? title
        
        let subtitle = onix["DescriptiveDetail"]["TitleDetail"]["TitleElement"]["Subtitle"]["content"].string
        let subtitleCollation = onix["DescriptiveDetail"]["TitleDetail"]["TitleElement"]["Subtitle"]["collationkey"].string ?? subtitle
        
        let contributorsArray = onix["DescriptiveDetail"]["Contributor"].array ?? []
        let contributors = contributorsArray
            .map{ ($0["ContributorRole"][0].string ?? "", $0["PersonName"]["content"].string ?? "", $0["PersonName"]["collationkey"].string ?? "") }
            .filter{ $0.0 != "" && $0.1 != "" }
        let contributorRoles = contributors.map{ $0.0 }
        let contributorNames = contributors.map{ $0.1 }
        let contributorsCollations:[String] = {
            let collations = contributors.map{ $0.2 }
            if collations.filter({ $0 != "" }).count < contributorNames.count {
                return contributorNames
            } else {
                return collations
            }
        }()
        
        let textContents = onix["CollateralDetail"]["TextContent"].array?.map{ ($0["TextType"].string ?? "", $0["Text"].string ?? "") }.filter{ $0.0 != "" && $0.1 != "" } ?? []
        let bookDescription = textContents.filter{ $0.0 == "03" }.first?.1
        let tableOfContents = textContents.filter{ $0.0 == "04" }.first?.1
        
        let extentValueStr = onix["DescriptiveDetail"]["Extent"][0]["ExtentValue"].string
        let extentValue = extentValueStr != nil ? (Int16(extentValueStr!) ?? 0) : 0
        
        let summary = contents["summary"]
        let resourceLink = summary["cover"].string != nil ? URL(string: summary["cover"].string!) : nil
        let publisher = summary["publisher"].string
        
        let publishedDate: Date? = {
            guard let publishingDateStr = summary["pubdate"].string else {
                return nil
            }
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = publishingDateStr.count == 7 ? [.withYear, .withMonth, .withDashSeparatorInDate] :  [.withYear, .withMonth, .withDay]
            
            return formatter.date(from: publishingDateStr)
        }()


        let downloadedRecord = DownloadedRecord(
            isbn: isbn,
            title: title,
            titleCollation: titleCollation,
            subtitle: subtitle,
            subtitleCollation: subtitleCollation,
            contributorRoles: contributorRoles,
            contributorNames: contributorNames,
            contributorCollations: contributorsCollations,
            bookDescription: bookDescription,
            tableOfContents: tableOfContents,
            extentValue: extentValue,
            resourceLink: resourceLink,
            publisher: publisher,
            publishedDate: publishedDate)
        
        return downloadedRecord
    }
    
    class func downloadRecord(_ isbn:String, completion:@escaping (Result<DownloadedRecord, OpenBDAPIError>)->()) {
        let url = URL(string: "https://api.openbd.jp/v1/get?isbn=\(isbn)")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            let unknownError = OpenBDAPIError.unknown
            let notFoundError = OpenBDAPIError.notFound
            
            if let _ = error {
                completion(.failure(unknownError))
                return
            }
        
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(unknownError))
                return
            }
            
            guard let mimeType = httpResponse.mimeType, let data = data else {
                completion(.failure(notFoundError))
                return
            }
            
            if mimeType != "application/json" {
                completion(.failure(notFoundError))
                return
            }
            
            guard let json = try? JSON(data: data) else {
                completion(.failure(notFoundError))
                return
            }
                    
            guard let record = OpenBDAPI.parseDownloadedJson(isbn: isbn, json: json) else {
                completion(.failure(notFoundError))
                return
            }
                    
            completion(.success(record))
        }
        
        task.resume()
    }
}
