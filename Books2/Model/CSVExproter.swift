//
//  CSVExproter.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/13.
//

import Foundation
import CoreData

class CSVExporter: ObservableObject {
    
    private lazy var exportQueue: OperationQueue = {
        let queue = OperationQueue()
        return queue
    }()
    
    private let headerComponents = [
        "ISBN",
        "Title",
        "Subtitle",
        "Contributor names",
        "Description",
        "Table of Contents",
        "Number of pages",
        "Publisher",
        "Published",
        "Image URL",
        "Added",
        "User note"
    ]
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
    
    private lazy var exportDirectory: URL = {
        let directoryName = "exports"
        let directoryUrl = FileManager.default.temporaryDirectory.appendingPathComponent(directoryName)
        if !FileManager.default.fileExists(atPath: directoryUrl.path) {
            do {
                try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
            } catch {
                fatalError("error: \(error)")
            }
        }
        return directoryUrl
    }()
    
    @Published var fileUrl:URL?
    
    func export() {
        exportQueue.addOperation {
            [weak self] in
            guard let self = self else { return }
            self.removeExportDirectoryContents()
            
            let backgorundContext = PersistenceController.shared.container.backgroundContext()
            let fetchRequest: NSFetchRequest<BookInfo> = BookInfo.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \BookInfo.addedDate, ascending: false)]
            let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: backgorundContext, sectionNameKeyPath: nil, cacheName: nil)
            do {
                try controller.performFetch()
            } catch {
                fatalError("###\(#function): Failed to performFetch: \(error)")
            }
            
            guard let bookInfoObjects = controller.fetchedObjects else {
                return
            }
            let headerLine = self.generateLine(components: self.headerComponents)
            let bookInfoLines = bookInfoObjects.map{ self.generateBookInfoLine(bookInfo: $0) }
            let csvText = "\u{FEFF}" + self.generateCSVString(lines: [headerLine] + bookInfoLines)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYYMMdd-HHmmss"
            
            let fileName = "export-" + formatter.string(from: Date()) + ".csv"
            
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            do {
                try csvText.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                fatalError("###\(#function): Failed to write csv file: \(error)")
            }
            
            DispatchQueue.main.async {
                self.fileUrl = url
            }
        }
    }
    
    private func removeExportDirectoryContents() {
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: exportDirectory, includingPropertiesForKeys: nil, options: [])
            urls.forEach{ try? FileManager.default.removeItem(at: $0) }
        } catch {
            fatalError("###\(#function): Failed to remove export directory contents: \(error)")
        }
    }

    private func generateCSVString(lines: [String]) -> String {
        lines.reduce("") { (result, str) -> String in
            if result == "" {
                return str
            } else {
                return result + "\n" + str
            }
        }
    }
    
    private func generateBookInfoLine(bookInfo: BookInfo) -> String {
        generateLine(components: generateBookInfoComponents(bookInfo: bookInfo))
    }
    
    private func generateBookInfoComponents(bookInfo: BookInfo) -> [String] {
        [
            bookInfo.isbn ?? "",
            bookInfo.title ?? "",
            bookInfo.subtitle ?? "",
            generateComponent(array: bookInfo.contributorNames ?? []),
            bookInfo.bookDescription ?? "",
            bookInfo.tableOfContents ?? "",
            String(bookInfo.extentValue),
            bookInfo.publisher ?? "",
            bookInfo.publishedDate != nil ? dateFormatter.string(from: bookInfo.publishedDate!) : "",
            bookInfo.resourceLink?.absoluteString ?? "",
            bookInfo.addedDate != nil ? dateFormatter.string(from: bookInfo.addedDate!) : "",
            bookInfo.userNote ?? ""
        ]
    }
    
    private func generateComponent(array: [String]) -> String {
        array.reduce("") { (result, str) -> String in
            if result == "" {
                return str
            } else {
                return result + "," + str
            }
        }
    }
    
    private func generateLine(components: [String]) -> String{
        let escaped = components.map{ $0.replacingOccurrences(of: "\"", with: "\"\"")}
        let quoted = escaped.map{ "\"" + $0 + "\"" }
        let line = quoted.reduce("") { (result, str) -> String in
            if result == "" {
                return str
            } else {
                return result + "," + str
            }
        }
        return line
    }
}

extension URL: Identifiable {
    public var id: String {
        absoluteString
    }
}
