//
//  WeatherPredictionView.swift
//  Weather
//
//  Created by Ryan A Snell on 3/4/25.
//


struct WeatherPredictionView: View {
    @StateObject private var viewModel = WeatherViewModel()
    
    var body: some View {
        VStack {
            Text("Predicted Trend: \(viewModel.predictedTrend)")
                .font(.title)
                .padding()
            
            Button("Predict Weather") {
                viewModel.updatePrediction(temperature: 25.0, humidity: 60.0, windSpeed: 5.0)
            }
            .padding()
        }
    }
}