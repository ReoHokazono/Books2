//
//  SceneDelegate.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/30.
//

import UIKit
import SwiftUI
import CoreSpotlight
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let persistenceController = PersistenceController.shared

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView().environment(\.managedObjectContext, persistenceController.container.viewContext)
        let emptyDetailView = EmptyDetailView()
        
        let splitViewController = UISplitViewController(style: .doubleColumn)
        splitViewController.setViewController(UIHostingController(rootView: contentView), for: .primary)
        if UIDevice.current.userInterfaceIdiom == .pad {
            splitViewController.setViewController(UIHostingController(rootView: emptyDetailView), for: .secondary)
        }
        splitViewController.preferredDisplayMode = .oneBesideSecondary
        splitViewController.preferredSplitBehavior = .tile
        NotificationCenter.default.addObserver(forName: .bookInfoSelected, object: nil, queue: .main) { (notification) in
            guard let bookInfo = notification.object as? BookInfo else { return }
            let bookDetail = BookDetail(bookInfo: bookInfo).environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            let navigationController = UINavigationController(rootViewController: UIHostingController(rootView: bookDetail))
            splitViewController.setViewController(navigationController, for: .secondary)
            splitViewController.show(.secondary)
        }
        splitViewController.show(.primary)

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = splitViewController
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {

        guard let splitViewController = window?.rootViewController as? UISplitViewController else {
            return
        }
        
        guard let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else {
            return
        }
        let predicate = NSPredicate(
            format: "%K LIKE %@",
            #keyPath(BookInfo.bookInfoId), identifier)
        let fetchRequest = NSFetchRequest<BookInfo>(entityName: "BookInfo")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "bookInfoId", ascending: true)]
        
        let fetchResultsController = NSFetchedResultsController<BookInfo>(fetchRequest: fetchRequest, managedObjectContext: persistenceController.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchResultsController.performFetch()
        } catch {
            print("error \(error)")
        }
        
        guard let bookInfo = fetchResultsController.fetchedObjects?.first else {
            return
        }
        NotificationCenter.default.post(name: .bookInfoSearched, object: bookInfo)
        let bookDetail = BookDetail(bookInfo: bookInfo).environment(\.managedObjectContext, persistenceController.container.viewContext)
        let navigationController = UINavigationController(rootViewController: UIHostingController(rootView: bookDetail))
        splitViewController.setViewController(navigationController, for: .secondary)
        splitViewController.show(.secondary)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

