//
//  LocationHistoryView.swift
//  Weather
//
//  Created by Ryan A Snell on 2/18/25.
//

import SwiftUI
import SwiftData

struct LocationHistoryView: View {
    // Use @Query to get saved locations, sorted by timestamp
    @Query(sort: \SavedLocation.timestamp, order: .reverse) private var savedLocations: [SavedLocation]

    var body: some View {
        VStack {
            // Check if there are any saved locations
            if savedLocations.isEmpty {
                Text("No saved locations")
                    .padding()
            } else {
                List(savedLocations) { location in
                    VStack(alignment: .leading) {
                        Text(location.name)
                            .font(.headline)
                        Text("Lat: \(location.latitude), Lon: \(location.longitude)")
                            .font(.subheadline)
                        Text("\(location.timestamp.formatted(date: .numeric, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationTitle("Location History")
        .onAppear {
            // Trigger a reload of data when the view appears
            // If you are not seeing new data, you might want to call a refresh function here
        }
    }
}
