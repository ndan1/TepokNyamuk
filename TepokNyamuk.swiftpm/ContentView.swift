import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var gameManager = GameManager()
    var body: some View {
        ZStack {
            Image("table")
                .resizable()
                .ignoresSafeArea()
            
            switch gameManager.currentScreen {
            case .menu:
                MenuView()
            case .tutorial:
                TutorialView()
            case .playing:
                GameplayView()
            }
        }
        .environmentObject(gameManager)
    }
}
