//
//  Persistence.swift
//  Books2
//
//  Created by 外園玲央 on 2020/10/27.
//

import CoreData

extension NSPersistentContainer {
    func backgroundContext() -> NSManagedObjectContext {
        let context = newBackgroundContext()
        context.name = "app"
        return context
    }
}

class PersistenceController {
    static let shared = PersistenceController()
    let appTransactionAuthorName = "app"
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        return result
    }()

    var container: NSPersistentCloudKitContainer!
    
    var lastToken: NSPersistentHistoryToken? = nil {
        didSet {
            guard let token = lastToken,
                  let data = try? NSKeyedArchiver.archivedData(
                    withRootObject: token,
                    requiringSecureCoding: true
                  ) else { return }
            do {
                try data.write(to: tokenFile)
            } catch {
                let message = "Could not write token data"
                print("###\(#function): \(message): \(error)")
            }
        }
    }
    
    lazy var tokenFile: URL = {
        let url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Books2", isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(
                    at: url,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                let message = "Could not create persistent container URL"
                print("###\(#function): \(message): \(error)")
            }
        }
        return url.appendingPathComponent("token.data", isDirectory: false)
    }()
    
    private lazy var historyQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    func setupContainer(inMemory: Bool = false) -> NSPersistentCloudKitContainer {
        let container = NSPersistentCloudKitContainer(name: "Books2")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("###\(#function): Failed to retrieve a persistent store description.")
        }

        
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        container.viewContext.transactionAuthor = appTransactionAuthorName
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }
    
    init(inMemory: Bool = false) {
        self.container = setupContainer(inMemory: inMemory)
        
        NotificationCenter.default.addObserver(self, selector: #selector(storeRemoteChange(_:)), name: .NSPersistentStoreRemoteChange, object: nil)
        purgeHistory()
    }
    
    @objc
    func storeRemoteChange(_ notification: Notification) {
        historyQueue.addOperation {
            self.processPersistentHistory()
        }
    }
    
    func processPersistentHistory() {
        let taskContext = container.backgroundContext()
        taskContext.performAndWait {
            
            let historyFetchRequest = NSPersistentHistoryTransaction.fetchRequest!
            historyFetchRequest.predicate = NSPredicate(format: "author != %@", appTransactionAuthorName)
            
            let fetchHistoryRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: lastToken)
            fetchHistoryRequest.fetchRequest = historyFetchRequest
            
            guard let historyResult = try? taskContext.execute(fetchHistoryRequest) as? NSPersistentHistoryResult,
                  let transactions = historyResult.result as? [NSPersistentHistoryTransaction],
                  !transactions.isEmpty else { return }
            
            transactions.reversed().forEach { transaction in
                transaction.changes?.forEach({ (change) in
                    
                    if change.changeType == .insert {
                        if let bookInfo = taskContext.object(with: change.changedObjectID) as? BookInfo {
                            SpotlightManager.updateItem(item: bookInfo)
                        }
                    }
                    if change.changeType == .delete {
                        if let deletedBookInfoId = change.tombstone?["bookInfoId"] as? String {
                            SpotlightManager.removeItemFromIndex(bookInfoId: deletedBookInfoId)
                        }
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .itemDeleted, object: change.changedObjectID)
                        }
                    }
                })
            }
            guard let token = transactions.last?.token else { return }
            self.lastToken = token
        }
    }
    
    func purgeHistory(deleteAll: Bool = false) {
        let sevenDaysAgo = Date(timeIntervalSinceNow: TimeInterval(exactly: -604_800)!)
        let purgeHistoryRequest =
            NSPersistentHistoryChangeRequest.deleteHistory(
                before: sevenDaysAgo)

        do {
            try container.backgroundContext().execute(purgeHistoryRequest)
        } catch {
            fatalError("Could not purge history: \(error)")
        }
    }
}
