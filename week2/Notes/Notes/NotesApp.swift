//
//  NotesApp.swift
//  Notes
//
//  Created by Ryan A Snell on 2/17/25.
//

import SwiftUI

@main
struct NotesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NotesView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
