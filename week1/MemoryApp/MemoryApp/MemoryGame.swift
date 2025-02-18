//
//  MemoryGame.swift
//  MemoryApp
//
//  Created by Ryan A Snell on 2/17/25.
//

import Foundation

struct MemoryGame<CardContent> where CardContent: Equatable{
    private(set) var cards: Array<Card>
    
    init(numberOfPairsOfCards: Int, cardContentFactory: (Int) -> CardContent) {
        cards = []
        
        // add numberOfPairsOfCards x 2
        for pairIndex in 0..<max(2, numberOfPairsOfCards) {
            let content: CardContent = cardContentFactory(pairIndex)
            cards.append(Card(content: content, id: "\(pairIndex+1)a"))
            cards.append(Card(content: content, id: "\(pairIndex+1)b"))
        }
    }// end init
    
    var indexOfTheOneAndOnlyFaceUpCard: Int? {
        get{ cards.indices.filter { index in cards[index].isFaceUp }.only}
        set { cards.indices.forEach { cards[$0].isFaceUp = (newValue == $0) } }
    }// end var
    
    mutating func choose(_ card: Card) {
        if let choosenIndex = cards.firstIndex(where: { $0.id == card.id}) {
            if !cards[choosenIndex].isFaceUp && !cards[choosenIndex].isMatched {
                if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
                    if cards[choosenIndex].content == cards[potentialMatchIndex].content {
                        cards[choosenIndex].isMatched = true
                        cards[potentialMatchIndex].isMatched = true
                    }
                }else {
                    indexOfTheOneAndOnlyFaceUpCard = choosenIndex
                }
                cards[choosenIndex].isFaceUp = true
            }
        }
    }// end func
    
//   private func index(of card: Card) -> Int? {
//        for index in cards.indices {
//            if cards[index].id == card.id {
//                return index
//            }
//        }
//        return nil
//    }// end func
    
    mutating func shuffle() {
        cards.shuffle()
        print(cards)
    }// end func
    
    struct Card: Equatable, Identifiable, CustomDebugStringConvertible {
        var isFaceUp: Bool = false
        var isMatched: Bool = false
        let content: CardContent
        
        var id: String
        var debugDescription: String {
            "\(id):\(content) \(isFaceUp ? "up" : "down") \(isMatched ? "matched" : "")"
        }
    }// end struct
    
}// end struct

extension Array {
    var only: Element? {
        count == 1 ? first : nil
    }
}
