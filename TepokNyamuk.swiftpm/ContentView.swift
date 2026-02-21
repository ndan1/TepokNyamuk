import SwiftUI
import AVFoundation

enum AppScreen {
    case menu
    case tutorial
    case playing
}

struct ContentView: View {
    
    @State private var currentScreen: AppScreen = .menu
    
    // Game Mechanic
    @State private var currentSystemNumber = 1
    @State private var currentCardValue = 1
    @State private var currentSuit = "spades"
    @State private var isPaused = false
    @State private var gameTimer: Timer?
    private let synthesizer = AVSpeechSynthesizer()
    
    // Countdown
    @State private var isCountingDown = false
    @State private var countdownValue = 3
    
    // Hand Slap
    @State private var showingHand = false
    @State private var handAngle: Double = 0
    
    // Score
    @State private var scoreP1: Int = 0
    @State private var scoreP2: Int = 0
    @State private var isFrozenP1 = false
    @State private var isFrozenP2 = false
    
    // Feedback text
    @State private var feedbackMessage = ""
    @State private var showFeedback = false
    
    // Game Over or Win
    let winningScore = 1
    @State private var gameOver = false
    @State private var winnerText = ""
    
    var body: some View {
        ZStack {
            Image("table")
                .resizable()
                .ignoresSafeArea()
            
            switch currentScreen {
            case .menu:
                menuView
            case .tutorial:
                tutorialView
            case .playing:
                gameView
            }
        }
    }
    
    var menuView: some View {
        VStack (spacing: 32) {
            Text("Tepok Nyamuk")
                .font(.system(size: 60, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black, radius: 10, x: 5, y: 5)
                .padding(.top, 50)
            
            Spacer()
            
            Button(action: {
                currentScreen = .playing
                resetGame()
            }) {
                Text("Play")
                    .font(.title).bold()
                    .foregroundColor(.white)
                    .frame(width: 220)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(20)
                    .shadow(radius: 5)
            }
            
            Button(action: {
                currentScreen = .tutorial
            }) {
                Text("Tutorial")
                    .font(.title).bold()
                    .foregroundColor(.white)
                    .frame(width: 220)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(20)
                    .shadow(radius: 5)
            }
            
            Spacer()
        }
    }
    
    var tutorialView: some View {
        VStack {
            Spacer()
            
            VStack (spacing: 20) {
                Text("How to Play")
                    .font(.title).bold()
                    .foregroundColor(.white)
                
                Text("Lorem ipsum dolor sit amet consectetur adipisicing elit. Quo, voluptatem!")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button {
                    currentScreen = .menu
                } label: {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .padding(30)
            .background(Color.black.opacity(0.9))
            .cornerRadius(20)
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    var gameView: some View {
        ZStack {
            VStack (spacing: 0) {
                VStack {
                    Text(getSpokenWord(for: currentSystemNumber))
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 15)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(16)
                    Spacer()
                    Text("Skor: \(scoreP2)")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.32)
                .rotationEffect(Angle(degrees: 180))
                
                Image(getCardImageName(value: currentCardValue, suit: currentSuit))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .shadow(color: .black.opacity(0.5), radius: 10, x:5, y:5)
                    .padding(.vertical, 30)
                
                VStack {
                    Text(getSpokenWord(for: currentSystemNumber))
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 15)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(16)
                    Spacer()
                    Text("Skor: \(scoreP1)")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.32)
                    
            }
            .opacity(isCountingDown ? 0 : 1)
            VStack (spacing: 0) {
                ZStack {
                    Color.white.opacity(0.001).contentShape(Rectangle())
                    if isFrozenP2 {
                        Color.cyan.opacity(0.3).ignoresSafeArea()
                        Text("FROZEN")
                            .font(.system(size: 32, weight: .heavy))
                            .foregroundStyle(.white)
                            .rotationEffect(Angle(degrees: 180))
                    }
                }
                .onTapGesture {
                    playerTapped(player: 2)
                }
                ZStack {
                    Color.white.opacity(0.001).contentShape(Rectangle())
                    if isFrozenP1 {
                        Color.cyan.opacity(0.3).ignoresSafeArea()
                        Text("FROZEN")
                            .font(.system(size: 32, weight: .heavy))
                            .foregroundStyle(.white)
                    }
                }
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
            
            if showFeedback {
                Text(feedbackMessage)
                    .font(.title2)
                    .foregroundColor(.white)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(16)
                    .rotationEffect(.degrees(handAngle))
                    .transition(.scale.combined(with: .opacity))
            }
            
            if isCountingDown {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                Text(countdownValue > 0 ? "\(countdownValue)" : "Start!")
                    .font(.system(size: countdownValue > 0 ? 120 : 180, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 10, x: 5, y: 5)
                    .scaleEffect(countdownValue > 0 ? 1.0 : 1.3)
                    .transition(.scale.combined(with: .opacity))
                    .id(countdownValue)
            }
            
            if gameOver {
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                
                VStack (spacing: 40) {
                    Text(winnerText)
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(.yellow)
                        .multilineTextAlignment(.center)
                        .shadow(color: .orange, radius: 10, x: 0, y: 0)
                    VStack (spacing: 24) {
                        Button {
                            resetGame()
                        } label: {
                            Text("Play Again")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(.white)
                                .frame(width: 200)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 15)
                                .background(Color.green)
                                .cornerRadius(20)
                                .shadow(radius: 5)
                        }
                        
                        Button {
                            gameTimer?.invalidate()
                            synthesizer.stopSpeaking(at: .immediate)
                            gameOver = false
                            currentScreen = .menu
                        } label: {
                            Text("Menu")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(.white)
                                .frame(width: 200)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 15)
                                .background(Color.red)
                                .cornerRadius(20)
                                .shadow(radius: 5)
                        }
                    }
                }
                .transition(.scale)
            }
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
    
    func resetGame() {
        gameTimer?.invalidate()
        synthesizer.stopSpeaking(at: .immediate)
        
        scoreP1 = 0
        scoreP2 = 0
        isFrozenP1 = false
        isFrozenP2 = false
        currentSystemNumber = 1
        gameOver = false
        isPaused = false
        showingHand = false
        showFeedback = false
        
        currentCardValue = Int.random(in: 1...13)
        let suits = ["spades", "hearts", "diamonds", "clubs"]
        currentSuit = suits.randomElement() ?? "spades"
        
        isCountingDown = true
        countdownValue = 3
        runCountdown()
    }
    
    func runCountdown() {
        guard currentScreen == .playing && isCountingDown else { return }
        
        if countdownValue > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    countdownValue -= 1
                }
                runCountdown()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isCountingDown = false
                }
                speak(word: getSpokenWord(for: currentSystemNumber))
                startTimer()
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
        guard !isCountingDown else { return }
        
        guard !isPaused else { return }
        if player == 1 && isFrozenP1 { return }
        if player == 2 && isFrozenP2 { return }
        
        isPaused = true
        gameTimer?.invalidate()
        synthesizer.stopSpeaking(at: .immediate)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            showingHand = true
            handAngle = player == 1 ? 0 : 180
        }
        
        let isCorrect = (currentSystemNumber == currentCardValue)
        
        var triggerFreezeP1: Bool = false
        var triggerFreezeP2: Bool = false
        
        if isCorrect {
            if player == 1 {
                scoreP1 += 1
            } else {
                scoreP2 += 1
            }
            feedbackMessage = "Player \(player) got it! \n +1 point"
        } else {
            if player == 1 {
                scoreP1 -= 1
                if scoreP1 < 0 {
                    scoreP1 = 0
                    isFrozenP1 = true
                    feedbackMessage = "Player 1 slap the wrong card! \n Freeze 5 second"
                    triggerFreezeP1 = true
                } else {
                    feedbackMessage = "Player 1 slap the wrong card! \n -1 point"
                }
            } else {
                scoreP2 -= 1
                if scoreP2 < 0 {
                    scoreP2 = 0
                    isFrozenP2 = true
                    feedbackMessage = "Player 2 slap the wrong card! \n Freeze 5 second"
                    triggerFreezeP2 = true
                } else {
                    feedbackMessage = "Player 2 slap the wrong card! \n -1 point"
                }
            }
        }
        
        withAnimation {
            showFeedback = true
        }
        
        var isGameFinished = false
        if scoreP1 >= winningScore {
            winnerText = "Player 1 Win"
            isGameFinished = true
        } else if scoreP2 >= winningScore {
            winnerText = "Player 2 Win"
            isGameFinished = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showingHand = false
                showFeedback = false
            }
            
            if isGameFinished {
                withAnimation{ gameOver = true }
            } else {
                isPaused = false
                
                if triggerFreezeP1 {
                    unfreeze(player: 1)
                }
                if triggerFreezeP2 {
                    unfreeze(player: 2)
                }
                
                nextTurn()
                startTimer()
            }
        }
    }
    
    func unfreeze(player: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            withAnimation {
                if player == 1 {
                    isFrozenP1 = false
                } else {
                    isFrozenP2 = false
                }
            }
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
