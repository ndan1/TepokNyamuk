import SwiftUI
import AVFoundation

struct ContentView: View {
    
    @State private var currentSystemNumber = 1
    @State private var currentCardValue = 1
    @State private var currentSuit = "spades"
    
    @State private var isPaused = false
    @State private var showingHand = false
    @State private var handAngle: Double = 0
    
    @State private var gameTimer: Timer?
    private let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        ZStack {
            Image("table")
                .ignoresSafeArea()
            
            VStack (spacing: 0) {
                Text(getSpokenWord(for: currentSystemNumber))
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 15)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(16)
                    .rotationEffect(Angle(degrees: 180))
                
                Image(getCardImageName(value: currentCardValue, suit: currentSuit))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .shadow(color: .black.opacity(0.5), radius: 10, x:5, y:5)
                    .padding(.vertical, 30)
                
                Text(getSpokenWord(for: currentSystemNumber))
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 15)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(16)
                    
            }
            VStack (spacing: 0) {
                Color.white.opacity(0.001)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        playerTapped(player: 2)
                    }
                Color.white.opacity(0.001)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        playerTapped(player: 1)
                    }
            }
            Image("hand")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .rotationEffect(Angle(degrees: handAngle))
                .shadow(radius: 10)
                .scaleEffect(showingHand ? 1.0 : 1.5)
                .opacity(showingHand ? 1 : 0)
        }
        .onAppear {
            speak(word: getSpokenWord(for: currentSystemNumber))
            startTimer()
        }
    }
    
    func startTimer() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                nextTurn()
            }
        }
    }
    
    func nextTurn() {
        guard !isPaused else { return }
        
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
    
    func playerTapped(player: Int) {
        guard !isPaused else { return }
        
        isPaused = true
        gameTimer?.invalidate()
        synthesizer.stopSpeaking(at: .immediate)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            showingHand = true
            handAngle = player == 1 ? 0 : 180
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showingHand = false
            }
            isPaused = false
            nextTurn()
            startTimer()
        }
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
