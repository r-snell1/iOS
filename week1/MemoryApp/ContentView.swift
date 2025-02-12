//
//  ContentView.swift
//  MemoryApp
//
//  Created by Ryan A Snell on 2/11/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    let emojis: Array<String> = ["👻", "💀", "👹", "👽","👺", "🧙", "🎃", "🤡", "🦇","😺","🕷️","🤖"]
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State var cardCount: Int = 4
    var body: some View {
        VStack {
            ScrollView {
                cards
            }
            Spacer()
            cardCountAdjusters
        }// end outer most vstack
        .padding()
    }// body
    
    func cardCountAdjuster(by offset: Int, symbol: String) -> some View {
        Button(action: {
            cardCount += offset
        }, label: {
            Image(systemName: symbol)
        })
        .disabled(cardCount + offset < 1 || cardCount + offset > emojis.count)
    }
    
    var cardRemover: some View{
        return cardCountAdjuster(by: -1, symbol: "rectangle.stack.badge.minus.fill")
    }// end cardRemover
    var cardAdder: some View{
        return cardCountAdjuster(by: +1, symbol: "rectangle.stack.badge.plus.fill")
    }// end cardAdder
    
    var cards: some View {
        LazyVGrid(columns:[GridItem(.adaptive(minimum: 120))]){
            ForEach(0..<cardCount, id: \.self) { idx in
                CardView(content: emojis[idx])
                    .aspectRatio(2/3, contentMode: .fit)
            }
        }
    }// end cards
    
    var cardCountAdjusters: some View{
        HStack{
            cardRemover
            Spacer()
            cardAdder
        }
        .imageScale(.large)
        .font(.largeTitle)
    }// end cardCountAdjusters
    
}// end struct

struct CardView: View {
    let content: String
    @State var isFaceUp = false
    
    var body: some View {
        ZStack{
            let base = RoundedRectangle(cornerRadius: 20)
            
            Group {
                base.fill(.blue)
                base.strokeBorder(Color.black, lineWidth: 4)
                Text(content).font(.largeTitle).padding()
            }
            .opacity(isFaceUp ? 1 : 0)
            base.fill(Color.orange).opacity(isFaceUp ? 0 : 1)
        }// end zstack
        .onTapGesture {
            withAnimation {
                print("tapped")
                isFaceUp.toggle()
            }
        }//end gesture
    }// end body
}// end struct



// for development to view in xcode
#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
