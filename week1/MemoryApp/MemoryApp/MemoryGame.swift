//
//  MemoryGame.swift
//  MemoryApp
//
//  Created by Ryan A Snell on 2/17/25.
//

import Foundation

struct MemoryGame<CardContent> {
    private(set) var cards: Array<Card>
    
    init(numberOfPairsOfCards: Int, cardContentFactory: (Int) -> CardContent) {
        cards = []
        
        // add numberOfPairsOfCards x 2
        for pairIndex in 0..<max(2, numberOfPairsOfCards) {
            let content: CardContent = cardContentFactory(pairIndex)
            cards.append(Card(content: content))
            cards.append(Card(content: content))
        }
    }// end init
    
    func choose(_ card: Card) {
        
    }// end func
    
    mutating func shuffle() {
        cards.shuffle()
        print(cards)
    }
    
    struct Card {
        var isFaceUp: Bool = true
        var isMatched: Bool = false
        let content: CardContent
        
    }// end struct
    
}// end struct
