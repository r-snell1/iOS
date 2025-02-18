//
//  EmojiMemoryView.swift
//  MemoryApp
//
//  Created by Ryan A Snell on 2/11/25.
//

import SwiftUI
import SwiftData

struct EmojiMemoryView: View {
    @ObservedObject var viewModel: EmojiMemoryGame
    let emojis: Array<String> = ["👻", "💀", "👹", "👽","👺", "🧙", "🎃", "🤡", "🦇","😺","🕷️","🤖"]
    
    var body: some View {
        VStack{
            ScrollView {
                cards
            }
            Button("Shuffle") {
                viewModel.shuffle()
            }
        }
        .padding()
    }// body
    
    var cards: some View {
        LazyVGrid(columns:[GridItem(.adaptive(minimum: 120),spacing: 0)], spacing: 0){
            ForEach(viewModel.cards.indices, id: \.self) { index in
                CardView(viewModel.cards[index])
                    .aspectRatio(2/3, contentMode: .fit)
                    .padding(4)
            }
        }
    }// end cards
    
}// end struct

struct CardView: View {
    let card: MemoryGame<String>.Card
    
    init(_ card: MemoryGame<String>.Card) {
        self.card = card
    }
    
    var body: some View {
        ZStack{
            let base = RoundedRectangle(cornerRadius: 20)
            
            Group {
                base.fill(.blue)
                base.strokeBorder(Color.black, lineWidth: 4)
                Text(card.content)
                    .font(.system(size: 200))
                    .minimumScaleFactor(0.01)
                    .aspectRatio(1, contentMode: .fit)
            }
            .opacity(card.isFaceUp ? 1 : 0)
            base.fill(Color.orange)
                .opacity(card.isFaceUp ? 0 : 1)
        }// end zstack
        
    }// end body
}// end struct



// for development to view in xcode
#Preview {
    EmojiMemoryView(viewModel: EmojiMemoryGame())
        .modelContainer(for: Item.self, inMemory: true)
}
