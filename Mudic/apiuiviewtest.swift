import SwiftUI

struct MoodRes: Codable {
    let mood: String
    let message: String
    let rgb: String
}

struct apiuiviewtest: View {
    @State private var userInput: String = ""
    @State private var mood: String = ""
    @State private var geminiMessage: String = ""
    @State private var rgb: String = ""
    @State private var phase: AppPhase = .input
    @State private var apiResponseReceived = false
    @State private var uiColor: Color = Color(red: 0.9, green: 0.8, blue: 0.95)
    @State private var textColor: Color = .black
    @State private var scaleEffect: CGFloat = 1.0

    enum AppPhase {
        case input, loading, result
    }

    let moodToPlaylist: [String: String] = [
        "Happy": "https://open.spotify.com/playlist/37i9dQZF1DXdPec7aLTmlC",
        "Sad": "https://open.spotify.com/playlist/10oMJOAD7j7U9XXL8nU9Q9",
        "Anxious": "https://open.spotify.com/playlist/2Q57Ffyd6UCyLYONAskwcD",
        "Angry": "https://open.spotify.com/playlist/4eFE32myVUKCpEV18VkpF3",
        "Tired": "https://open.spotify.com/playlist/37i9dQZF1DWZeKCadgRdKQ",
        "Stressed": "https://open.spotify.com/playlist/37i9dQZF1DWU0ScTcjJBdj"
    ]

    func startLoading() {
        self.phase = .loading
        self.apiResponseReceived = false
        analyzeMood()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if !self.apiResponseReceived {
                self.phase = .result
            }
        }
    }

    func analyzeMood() {
        guard let url = URL(string: "https://90ee-107-171-154-236.ngrok-free.app/api/analyze") else { return }

        let parameters = ["text": userInput]
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "No data")")
                return
            }

            if let decoded = try? JSONDecoder().decode(MoodRes.self, from: data) {
                DispatchQueue.main.async {
                    self.mood = decoded.mood
                    self.geminiMessage = decoded.message
                    self.rgb = decoded.rgb
                    self.setColors(from: decoded.rgb)
                    self.apiResponseReceived = true
                    self.phase = .result
                }
            }
        }.resume()
    }

    func setColors(from rgbString: String) {
        let numbers = rgbString
            .replacingOccurrences(of: "[^0-9,]", with: "", options: .regularExpression)
            .split(separator: ",")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }

        if numbers.count == 3 {
            let red = numbers[0] / 255.0
            let green = numbers[1] / 255.0
            let blue = numbers[2] / 255.0
            uiColor = Color(red: red, green: green, blue: blue)
            textColor = Color(red: max(red - 0.2, 0), green: max(green - 0.2, 0), blue: max(blue - 0.2, 0))
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                if phase == .input {
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

                } else if phase == .loading {
                    VStack {
                        Image(systemName: "sun.max.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color(red: 1.0, green: 250/256, blue: 150/256))
                            .frame(width: 100, height: 100)
                            .scaleEffect(scaleEffect)
                            .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: scaleEffect)
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

                } else if phase == .result {
                    VStack(spacing: 20) {
                        Text(geminiMessage)
                            .font(.title)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(textColor)
                            .padding(.horizontal, 30)
                            .padding(.top, 40)


                        Text("Mood: \(mood)")
                            .font(.headline)
                            .foregroundColor(textColor)
                            .padding()

                        if let playlistURL = moodToPlaylist[mood] {
                            Button(action: {
                                if let url = URL(string: playlistURL) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "music.note.list")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                    Text("Listen to a vibe-matching playlist")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 90/255, green: 180/255, blue: 140/255))
                                .cornerRadius(20)
                                .shadow(radius: 5)
                                .padding(.horizontal, 40)
                            }
                        }

                        if mood.lowercased() == "stressed" {
                            NavigationLink(destination: gamepage()) {
                                HStack {
                                    Image(systemName: "gamecontroller.fill")
                                        .foregroundColor(.white)
                                    Text("Play to relieve stress")
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(textColor)
                                .cornerRadius(20)
                                .shadow(radius: 5)
                                .padding(.horizontal, 40)
                            }
                        }
                        if mood.lowercased() == "happy" {
                            NavigationLink(destination: happypage()) {
                                HStack {
                                    Image(systemName: "leaf")
                                        .foregroundColor(.white)
                                    Text("haiku on your day today! ")
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(textColor)
                                .cornerRadius(20)
                                .shadow(radius: 5)
                                .padding(.horizontal, 40)
                            }
                        }
                        if mood.lowercased() == "angry" {
                            NavigationLink(destination: AngryPage()) {
                                HStack {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.white)
                                    Text("Let it out - Vent here")
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(textColor)
                                .cornerRadius(20)
                                .shadow(radius: 5)
                                .padding(.horizontal, 40)
                            }
                        }
                        if mood.lowercased() == "sad" {
                            NavigationLink(destination: SadPage()) {
                                HStack {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.white)
                                    Text("swipe out your sadness!")
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(textColor)
                                .cornerRadius(20)
                                .shadow(radius: 5)
                                .padding(.horizontal, 40)
                            }
                        }

                        Button(action: {
                            // Navigate back to input phase
                            phase = .input
                        }) {
                            Text("I feel different now")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .background(textColor)
                                .cornerRadius(20)
                                .shadow(radius: 5)
                        }
                        .padding(.top, 20)

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
}

#Preview {
    apiuiviewtest()
}
