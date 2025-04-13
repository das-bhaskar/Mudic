//
//  gamepage.swift
//

import SwiftUI

struct gamepage: View {
    @State private var counter = 0
    @State private var timeLeft = 10
    @State private var buttonPosition = CGPoint(x: 100, y: 100) // Initial position
    @State private var isGameActive = false // Tracks if the game is active
    @State private var timer: Timer? = nil
    @State private var backgroundColor = Color.black // Default background color
    
    let screenSize = UIScreen.main.bounds // Gets the screen bounds for random positioning
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                VStack {
                    Text("Time Left: \(timeLeft)")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                    
                    Text("Score: \(counter)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    if !isGameActive {
                        Button("Start Game") {
                            startGame()
                        }
                        .padding()
                        .font(.title2)
                        .buttonStyle(.borderedProminent)
                        .foregroundColor(.white)
                    }
                }
                
                if isGameActive {
                    Button(action: {
                        increaseCounter()
                        updateButtonPosition()
                    }) {
                        Image("hamsta") // Use the name of your image added to the asset catalog
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50) // Adjust the size as needed
                    }
                    .position(buttonPosition)
                }
            }
        }
    }
    
    func startGame() {
        counter = 0
        timeLeft = 10
        isGameActive = true
        updateButtonPosition()
        // Randomize background color when a new game starts
        backgroundColor = randomPastelColor()
        
        // Start a timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                endGame()
            }
        }
    }
    
    func endGame() {
        timer?.invalidate()
        timer = nil
        isGameActive = false
    }
    
    func increaseCounter() {
        counter += 1
    }
    
    func updateButtonPosition() {
        let safePadding: CGFloat = 50 // Ensures the button doesn’t go off-screen
        let xPosition = CGFloat.random(in: safePadding...(screenSize.width - safePadding))
        let yPosition = CGFloat.random(in: safePadding...(screenSize.height - safePadding))
        buttonPosition = CGPoint(x: xPosition, y: yPosition)
    }
    
    // Function to generate a random pastel color
    func randomPastelColor() -> Color {
        let red = CGFloat.random(in: 0.7...0.9)
        let green = CGFloat.random(in: 0.7...0.9)
        let blue = CGFloat.random(in: 0.7...0.9)
        return Color(red: red, green: green, blue: blue)
    }
}

#Preview {
    gamepage()
}
