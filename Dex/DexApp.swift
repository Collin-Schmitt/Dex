//
//  DexApp.swift
//  Dex
//
//  Created by Collin Schmitt on 4/22/25.
//

import SwiftUI

@main
struct DexApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
