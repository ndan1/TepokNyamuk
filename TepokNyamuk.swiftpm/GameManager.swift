//
//  File.swift
//  TepokNyamuk
//
//  Created by Lin Dan Christiano on 22/02/26.
//

import Foundation
import SwiftUI
import AVFoundation

enum AppScreen {
    case menu
    case tutorial
    case playing
}

class GameManager: ObservableObject {
    @Published var currentScreen: AppScreen = .menu
    
    // Game Mechanic
    @Published var currentSystemNumber = 1
    @Published var currentCardValue = 1
    @Published var currentSuit = "spades"
    @Published var isPaused = false
    @Published var gameTimer: Timer?
    let synthesizer = AVSpeechSynthesizer()
    var freezeTimer: Timer?
    @Published var freezeTimeRemainingP1: Double = 0
    @Published var freezeTimeRemainingP2: Double = 0
    
    // Countdown
    @Published var isCountingDown = false
    @Published var countdownValue = 3
    
    // Pause the game
    @Published var isUserPaused = false
    
    // Hand Slap
    @Published var showingHand = false
    @Published var handAngle: Double = 0
    
    // Score
    @Published var scoreP1: Int = 0
    @Published var scoreP2: Int = 0
    @Published var isFrozenP1 = false
    @Published var isFrozenP2 = false
    
    // Feedback text
    @Published var feedbackMessage = ""
    @Published var showFeedback = false
    
    // Game Over or Win
    let winningScore = 1
    @Published var gameOver = false
    @Published var winnerText = ""
    
    func startTimer() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                self.nextTurn()
            }
        }
        
        freezeTimer?.invalidate()
        freezeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                self.updateFreezeTime()
            }
        }
    }
    
    func updateFreezeTime() {
        guard !isPaused && !isUserPaused && !isCountingDown else { return }
        
        if isFrozenP1 && freezeTimeRemainingP1 > 0 {
            freezeTimeRemainingP1 -= 0.1
            if freezeTimeRemainingP1 <= 0 {
                withAnimation {
                    isFrozenP1 = false
                }
            }
        }
        
        if isFrozenP2 && freezeTimeRemainingP2 > 0 {
            freezeTimeRemainingP2 -= 0.1
            if freezeTimeRemainingP2 <= 0 {
                withAnimation {
                    isFrozenP2 = false
                }
            }
        }
    }
    
    func pauseGame() {
        guard !isCountingDown && !gameOver && !isPaused else { return }
        
        withAnimation {
            isUserPaused = true
        }
        
        gameTimer?.invalidate()
        freezeTimer?.invalidate()
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    func resumeGame() {
        withAnimation {
            isUserPaused = false
        }
        speak(word: getSpokenWord(for: currentSystemNumber))
        startTimer()
    }
    
    func resetGame() {
        gameTimer?.invalidate()
        freezeTimer?.invalidate()
        synthesizer.stopSpeaking(at: .immediate)
        
        scoreP1 = 0
        scoreP2 = 0
        isFrozenP1 = false
        isFrozenP2 = false
        freezeTimeRemainingP1 = 0
        freezeTimeRemainingP2 = 0
        currentSystemNumber = 1
        gameOver = false
        isPaused = false
        showingHand = false
        showFeedback = false
        isUserPaused = false
        
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
                    self.countdownValue -= 1
                }
                self.runCountdown()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.isCountingDown = false
                }
                self.speak(word: self.getSpokenWord(for: self.currentSystemNumber))
                self.startTimer()
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
        guard !isUserPaused else { return }
        guard !isPaused else { return }
        if player == 1 && isFrozenP1 { return }
        if player == 2 && isFrozenP2 { return }
        
        isPaused = true
        gameTimer?.invalidate()
        freezeTimer?.invalidate()
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in
            withAnimation(.easeInOut(duration: 0.2)) {
                showingHand = false
                showFeedback = false
            }
            
            if isGameFinished {
                withAnimation{ gameOver = true }
            } else {
                isPaused = false
                
                if triggerFreezeP1 {
                    freezeTimeRemainingP1 = 5.0
                }
                if triggerFreezeP2 {
                    freezeTimeRemainingP2 = 5.0
                }
                
                nextTurn()
                startTimer()
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
