import SwiftUI

struct MoodResponse: Codable {
    let mood: String
    let message: String
    let rgb: [Int]
}

struct ContentView: View {
    // App State
    @State private var userInput: String = ""
    @State private var mood: String = ""
    @State private var geminiMessage: String = ""
    @State private var uiColor: Color = Color(red: 0.9, green: 0.8, blue: 0.95)
    @State private var phase: AppPhase = .input
    @State private var scaleEffect: CGFloat = 1.0
    @State private var apiResponseReceived = false

    enum AppPhase {
        case input, loading, result
    }

    func startLoading() {
        self.phase = .loading
        self.apiResponseReceived = false
        analyzeMood()
        
        // Transition to the result page after 5 seconds, regardless of the API response
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if !self.apiResponseReceived {
                self.phase = .result
            }
        }
    }

    func analyzeMood() {
        guard let url = URL(string: "http://127.0.0.1:5000/api/analyze") else { return }
        
        let parameters = ["text": userInput]
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "No data")")
                return
            }

            if let decoded = try? JSONDecoder().decode(MoodResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.mood = decoded.mood
                    self.geminiMessage = decoded.message
                    self.uiColor = Color(
                        red: Double(decoded.rgb[0]) / 255.0,
                        green: Double(decoded.rgb[1]) / 255.0,
                        blue: Double(decoded.rgb[2]) / 255.0
                    )
                    self.apiResponseReceived = true
                    self.phase = .result
                }
            }
        }.resume()
    }

    var body: some View {
        VStack {
            if phase == .input {
                // Input screen
                Text("Hi, how are we feeling today?")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .padding(.top, 120)
                    .foregroundColor(Color(red: 70/256, green: 60/256, blue: 150/256))
                
                Spacer(minLength: 60)

                ZStack {
                    Color(red: 245/256, green: 230/256, blue: 220/256)
                        .cornerRadius(20)
                        .frame(height: 200)
                        .padding(.horizontal)

                    TextEditor(text: $userInput)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(Color(red: 247/256, green: 127/256, blue: 127/256))
                        .padding()
                        .background(Color.white.cornerRadius(20))
                        .frame(maxHeight: .infinity)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        .shadow(radius: 5)
                        .disableAutocorrection(true)
                }

                Spacer(minLength: 60)

                Button(action: {
                    startLoading()
                }) {
                    HStack(spacing: 10) {
                        Text("Check in ")
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Image(systemName: "sun.max.fill")
                            .foregroundColor(Color(red: 1.0, green: 250/256, blue: 150/256))
                            .font(.title)
                    }
                    .padding()
                    .background(Color(red: 225/256, green: 120/256, blue: 90/256))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                }
                .padding(.bottom, 60)
            }
            else if phase == .loading {
                // Loading screen
                VStack {
                    Image(systemName: "sun.max.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color(red: 1.0, green: 250/256, blue: 150/256))
                        .frame(width: 100, height: 100)
                        .scaleEffect(scaleEffect)
                        .animation(
                            Animation.easeInOut(duration: 1)
                                .repeatForever(autoreverses: true), value: scaleEffect
                        )
                        .padding(.top, 30)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 225/256, green: 120/256, blue: 90/256))
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                        scaleEffect = 1.7
                    }
                }
            }
            else if phase == .result {
                // Result screen with button to go to the next page
                VStack {
                    Button(action: {
                        // Proceed to next page with dynamic UI based on API response
                        print("Going to next page with mood: \(mood), message: \(geminiMessage), color: \(uiColor)")
                        // Example: Navigate to the next page or dynamically change UI elements
                    }) {
                        Text("Next")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(red: 225/256, green: 120/256, blue: 90/256))
                            .cornerRadius(20)
                            .shadow(radius: 5)
                    }
                    .padding(.bottom, 60)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(uiColor)
                .ignoresSafeArea()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(uiColor)
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
