//
//  SwiftUIView.swift
//  TepokNyamuk
//
//  Created by Lin Dan Christiano on 22/02/26.
//

import SwiftUI

struct GameplayView: View {
    @EnvironmentObject var gameManager: GameManager
    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                VStack {
                    Text(gameManager.getSpokenWord(for: gameManager.currentSystemNumber))
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 15)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(16)
                    Spacer()
                    Text("Score: \(gameManager.scoreP2)")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.32)
                .rotationEffect(Angle(degrees: 180))
                
                Image(gameManager.getCardImageName(value: gameManager.currentCardValue, suit: gameManager.currentSuit))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .shadow(color: .black.opacity(0.5), radius: 10, x:5, y:5)
                    .padding(.vertical, 30)
                
                VStack {
                    Text(gameManager.getSpokenWord(for: gameManager.currentSystemNumber))
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 15)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(16)
                    Spacer()
                    Text("Score: \(gameManager.scoreP1)")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.32)
                    
            }
            .opacity(gameManager.isCountingDown ? 0 : 1)
            VStack (spacing: 0) {
                ZStack {
                    Color.white.opacity(0.001).contentShape(Rectangle())
                    if gameManager.isFrozenP2 {
                        Color.cyan.opacity(0.3).ignoresSafeArea()
                        Text("FROZEN")
                            .font(.system(size: 32, weight: .heavy))
                            .foregroundStyle(.white)
                            .rotationEffect(Angle(degrees: 180))
                    }
                }
                .onTapGesture {
                    gameManager.playerTapped(player: 2)
                }
                ZStack {
                    Color.white.opacity(0.001).contentShape(Rectangle())
                    if gameManager.isFrozenP1 {
                        Color.cyan.opacity(0.3).ignoresSafeArea()
                        Text("FROZEN")
                            .font(.system(size: 32, weight: .heavy))
                            .foregroundStyle(.white)
                    }
                }
                .onTapGesture {
                    gameManager.playerTapped(player: 1)
                }
            }
            Image("hand")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .rotationEffect(Angle(degrees: gameManager.handAngle))
                .shadow(radius: 10)
                .scaleEffect(gameManager.showingHand ? 1.0 : 1.5)
                .opacity(gameManager.showingHand ? 1 : 0)
            
            if gameManager.showFeedback {
                Text(gameManager.feedbackMessage)
                    .font(.title2)
                    .foregroundColor(.white)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(16)
                    .rotationEffect(.degrees(gameManager.handAngle))
                    .transition(.scale.combined(with: .opacity))
                    .padding(.horizontal, 48)
            }
            
            if gameManager.isCountingDown {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                Text(gameManager.countdownValue > 0 ? "\(gameManager.countdownValue)" : "Start!")
                    .font(.system(size: gameManager.countdownValue > 0 ? 120 : 80, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 10, x: 5, y: 5)
                    .scaleEffect(gameManager.countdownValue > 0 ? 1.0 : 1.3)
                    .transition(.scale.combined(with: .opacity))
                    .id(gameManager.countdownValue)
            }
            
            if gameManager.gameOver {
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                
                VStack (spacing: 40) {
                    Text(gameManager.winnerText)
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(.yellow)
                        .multilineTextAlignment(.center)
                        .shadow(color: .orange, radius: 10, x: 0, y: 0)
                    VStack (spacing: 24) {
                        Button {
                            gameManager.resetGame()
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
                            gameManager.gameTimer?.invalidate()
                            gameManager.synthesizer.stopSpeaking(at: .immediate)
                            gameManager.gameOver = false
                            gameManager.currentScreen = .menu
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
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        gameManager.pauseGame()
                    } label: {
                        Image(systemName: "pause.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white.opacity(0.8))
                            .shadow(radius: 5)
                            .padding(.trailing, 20)
                    }
                }
                Spacer()
            }
            .opacity((gameManager.isCountingDown || gameManager.gameOver || gameManager.isUserPaused) ? 0 : 1)
            
            if gameManager.isUserPaused {
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                
                VStack (spacing: 30) {
                    Text("Game Paused")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(.bottom, 10)
                    
                    Button {
                        gameManager.resumeGame()
                    } label: {
                        Text("Resume")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .frame(width: 220)
                            .padding(.vertical, 15)
                            .background(Color.green)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    
                    Button {
                        gameManager.resetGame()
                    } label: {
                        Text("Restart")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .frame(width: 220)
                            .padding(.vertical, 15)
                            .background(Color.blue)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    
                    Button {
                        gameManager.gameTimer?.invalidate()
                        gameManager.synthesizer.stopSpeaking(at: .immediate)
                        gameManager.isUserPaused = false
                        gameManager.currentScreen = .menu
                    } label: {
                        Text("Back to Menu")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .frame(width: 220)
                            .padding(.vertical, 15)
                            .background(Color.red)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

#Preview {
    GameplayView()
}
