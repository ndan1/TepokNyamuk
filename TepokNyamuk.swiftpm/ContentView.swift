import SwiftUI
import AVFoundation

struct ContentView: View {
    
    @State private var currentSystemNumber = 1
    @State private var currentCardValue = 1
    @State private var currentSuit = "spades"
    
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    private let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        ZStack {
            Image("table")
                .ignoresSafeArea()
            VStack {
                Text(getSpokenWord(for: currentSystemNumber))
                    .font(.system(size: 45, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(16)
                
                Image(getCardImageName(value: currentCardValue, suit: currentSuit))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160)
                    .shadow(color: .black.opacity(0.5), radius: 10, x:5, y:5)
            }
        }
        
        .onReceive(timer) { _ in
            nextTurn()
        }
        
        .onAppear {
            speak(word: getSpokenWord(for: currentSystemNumber))
        }
    }
    
    func nextTurn() {
        if currentSystemNumber < 13 {
            currentSystemNumber += 1
        } else {
            currentSystemNumber = 1
        }
        
        currentCardValue = Int.random(in: 1...13)
        let suits = ["spades", "hearts", "diamonds", "clubs"]
        currentSuit = suits.randomElement() ?? "spades"
        
        speak(word: getSpokenWord(for: currentSystemNumber))
    }
    
    func getCardImageName(value: Int, suit: String) -> String {
        let valueStr: String
        switch value {
        case 1: valueStr = "A"
        case 11: valueStr = "J"
        case 12: valueStr = "Q"
        case 13: valueStr = "K"
        default: valueStr = String(format: "%02d", value)
        }
        return "card_\(suit)_\(valueStr)"
    }
    
    func getSpokenWord(for number: Int) -> String {
        switch number {
        case 1:
            return "Ace"
        case 2:
            return "2"
        case 3:
            return "3"
        case 4:
            return "4"
        case 5:
            return "5"
        case 6:
            return "6"
        case 7:
            return "7"
        case 8:
            return "8"
        case 9:
            return "9"
        case 10:
            return "10"
        case 11:
            return "Jack"
        case 12:
            return "Queen"
        case 13:
            return "King"
        default:
            return ""
        }
    }
    
    func speak(word: String) {
        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
    
}
