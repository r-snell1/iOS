//
//  LocationHistoryView.swift
//  Weather
//
//  Created by Ryan A Snell on 2/18/25.
//

import SwiftUI
import SwiftData

struct LocationHistoryView: View {
    @Environment(\.modelContext) private var modelContext
        @Query(sort: \SavedLocationModel.timestamp, order: .reverse) private var savedLocations: [SavedLocationModel]
        
        var body: some View {
            VStack {
                // Add this for debugging
                Text("Debug: Found \(savedLocations.count) locations")
                    .font(.caption)
                    .foregroundColor(.gray)
                // testing button
                Button("Add Test Location") {
                                let testLocation = SavedLocationModel(
                                    id: UUID(), name: "Test Location \(Date().formatted(date: .abbreviated, time: .shortened))",
                                    latitude: 35.0,
                                    longitude: -120.0,
                                    country: "US",
                                    timestamp: Date(),
                                    temp: 72.0,
                                    condition: "Sunny"
                                )
                                
                                SavedLocationModel.saveLocation(testLocation, context: modelContext)
                                print("Added test location")
                            }
                    .onAppear {
                        print("LocationHistoryView appeared with \(savedLocations.count) locations")
                        // Try fetching directly to compare
                        do {
                            let descriptor = FetchDescriptor<SavedLocationModel>()
                            let count = try modelContext.fetchCount(descriptor)
                            print("Direct fetch count: \(count)")
                        } catch {
                            print("Error counting: \(error)")
                        }
                    }
                
                
                
                
                
                if savedLocations.isEmpty {
                    Text(NSLocalizedString("No saved locations", comment: "Message when no locations are saved"))
                        .padding()
                } else {
                    List {
                        ForEach(savedLocations) { location in
                            VStack(alignment: .leading) {
                                Text("Name: \(location.name)")
                                    .font(.caption)
                                Text("Latitude: \(String(format: "%.2f", location.latitude))")
                                Text("Longitude: \(String(format: "%.2f", location.longitude))")
                                Text("Timestamp: \(location.timestamp)")
                                Text("Country: \(location.country)")
                                Text("Temperature: \(String(format: "%.1f", location.temp))°\(temperatureUnit())")
                                Text("Condition: \(location.condition)")
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteLocation)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("Location History", comment: "Location History"))
        }
    
    // Function to delete a saved location
    private func deleteLocation(at offsets: IndexSet) {
        for index in offsets {
            let locationToDelete = savedLocations[index]
            modelContext.delete(locationToDelete)
        }
    }
    
    private func temperatureUnit() -> String {
        if (Locale.current.measurementSystem == .metric){
            return "C"
        } else {
            return "F"
        }
    }
}
