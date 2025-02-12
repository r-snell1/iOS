//
//  ContentView.swift
//  MemoryApp
//
//  Created by Ryan A Snell on 2/11/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    var body: some View {
        VStack {
            HStack{
                CardView(isFaceUp: true)
                CardView()
                CardView()
                CardView()
            }
            HStack{
                CardView()
                CardView()
                CardView()
                CardView()
            }
            HStack{
                CardView()
                CardView()
                CardView()
                CardView()
            }
        }// end outer most vstack
        .foregroundColor(.orange)
        .padding()
    }// body
}// end struct

struct CardView: View {
    var isFaceUp: Bool = false
    var body: some View {
        ZStack(content: {
            if isFaceUp {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.blue)
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(style: StrokeStyle(lineWidth: 4))
                Text("👻").padding()
            } else {
                RoundedRectangle(cornerRadius: 20)
            }// end if else
        })// end zstack
    }// end body
}// end struct



// for development to view in xcode
#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
