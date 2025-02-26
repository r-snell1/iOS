//
//  Persistence.swift
//  Weather
//
//  Created by Ryan A Snell on 2/25/25.
//

import SwiftData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer
    let context: ModelContext

    init() {
        do {
            container = try ModelContainer(for: SavedLocationModel.self)
            context = ModelContext(container)
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }
}
