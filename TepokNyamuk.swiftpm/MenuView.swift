//
//  SwiftUIView.swift
//  TepokNyamuk
//
//  Created by Lin Dan Christiano on 22/02/26.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var gameManager: GameManager
    var body: some View {
        VStack (spacing: 32) {
            Text("Tepok Nyamuk")
                .font(.system(size: 60, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black, radius: 10, x: 5, y: 5)
                .padding(.top, 50)
            
            Spacer()
            
            Button(action: {
                gameManager.currentScreen = .playing
                gameManager.resetGame()
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
                gameManager.currentScreen = .tutorial
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
}

#Preview {
    MenuView()
}
