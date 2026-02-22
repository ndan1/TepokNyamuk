//
//  SwiftUIView.swift
//  TepokNyamuk
//
//  Created by Lin Dan Christiano on 22/02/26.
//

import SwiftUI

struct TutorialView: View {
    @EnvironmentObject var gameManager: GameManager
    var body: some View {
        VStack {
            Spacer()
            
            VStack (spacing: 20) {
                Text("How to Play")
                    .font(.title).bold()
                    .foregroundColor(.white)
                
                TabView {
                    tutorialPage(
                        imageName: "tutor_area",
                        title: "1. Know Your Tap Area",
                        desc: "Top half is Player 2. \nBottom half is Player 1.\nTap your side only!"
                    )
                    
                    tutorialPage(
                        imageName: "tutor_match",
                        title: "2. Focus",
                        desc: "Wait until the spoken/written number matches the card number shown in the center."
                    )
                                        
                    tutorialPage(
                        imageName: "tutor_score",
                        title: "3. Slap Fast!",
                        desc: "Be the first to slap your area to get +1 Point.\nFirst to \(gameManager.winningScore) Points wins!"
                    )
                                        
                    tutorialPage(
                        imageName: "tutor_freeze",
                        title: "4. Penalty",
                        desc: "Wrong slap makes you lose 1 Point.\nIf your score is 0 and you slap incorrectly, you FREEZE for 5 seconds."
                    )
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .frame(height: 480)
                
                Button {
                    withAnimation {
                        gameManager.currentScreen = .menu
                    }
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
            .frame(maxWidth: 350)
            .padding(.vertical, 20)
            .background(Color.black.opacity(0.9))
            .cornerRadius(20)
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    func tutorialPage(imageName: String, title: String, desc: String) -> some View {
        VStack (spacing: 20) {
            Text(title)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 280)
                .cornerRadius(12)
                .shadow(radius: 5)
            
            Text(desc)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.top, 10)
    }
}

#Preview {
    TutorialView()
}
