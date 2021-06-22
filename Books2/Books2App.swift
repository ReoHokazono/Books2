//
//  Books2App.swift
//  Books2
//
//  Created by 外園玲央 on 2020/10/27.
//

import SwiftUI

//@main
struct Books2App: App {
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
        
    }
}
