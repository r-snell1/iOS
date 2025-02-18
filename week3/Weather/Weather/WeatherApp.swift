//
//  WeatherApp.swift
//  Weather
//
//  Created by Ryan A Snell on 2/18/25.
//

import SwiftUI
import SwiftData

@main
struct WeatherApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([SavedLocation.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            WeatherView()
        }
        .modelContainer(sharedModelContainer)
    }
}
