//
//  EmojiMemoryGame.swift
//  MemoryApp
//
//  Created by Ryan A Snell on 2/17/25.
//

import SwiftUI

class EmojiMemoryGame: ObservableObject {
    private static let emojis = ["👻", "💀", "👹", "👽","👺", "🧙", "🎃", "🤡", "🦇","😺","🕷️","🤖"]
    
    private static func createMemoryGame() -> MemoryGame<String> {
        return MemoryGame(numberOfPairsOfCards: 12) { pairIndex in
            if emojis.indices.contains(pairIndex) {
                return emojis[pairIndex]
            } else {
                return "😬"
            }
            
        }
    }// end static func
    
    @Published private var model = createMemoryGame()
    
    
    var cards: [MemoryGame<String>.Card] {
        return model.cards
    }// end var
    
    // MARK: - Intents
    
    func shuffle() {
        model.shuffle()
    }
    
    func choose(_ card: MemoryGame<String>.Card) {
        model.choose(card)
    }// end func
    
}// end class
