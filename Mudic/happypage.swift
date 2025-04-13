import Foundation
import SwiftUI

struct HaikuRes: Codable {
    let haiku: String
}

struct happypage: View {
    @State private var userInput: String = ""
    @State private var haiku: String = ""
    @State private var isLoading: Bool = false
    @State private var showHaikuView = false

    var body: some View {
        ZStack {
            // Pastel yellow background
            Color(red: 0.6, green: 0.8, blue: 0.9)
                .ignoresSafeArea()

            // Sakura flower in top-right corner
            VStack {
                HStack {
                    Spacer()
                    Image("sakura_corner")
                        .resizable()
                        .frame(width: 400, height: 300)
                        .opacity(0.6)
                        .padding(.trailing, -20)
                        .padding(.top, -20)
                }
                Spacer()
            }
            .ignoresSafeArea()

            // Main content
            VStack(spacing: 5) {
                Text("Tell me about your day")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .padding(.top, 190)
                    .foregroundColor(Color(red: 70/256, green: 60/256, blue: 150/256))
                
                Spacer(minLength: 40)

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
                        .cornerRadius(20)
                        .padding(.horizontal)
                        .shadow(radius: 5)
                        .disableAutocorrection(true)
                }

                Spacer(minLength: 40)
                
                Button(action: {
                    getHaiku(from: userInput)
                }) {
                    Text("Get Your Haiku")
                        .foregroundColor(.white)
                        .fontWeight(.heavy)
                        .padding()
                        .shadow(radius: 3)
                        .background(Color(red: 225/256, green: 120/256, blue: 90/256))
                        .cornerRadius(20)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
                .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                if isLoading {
                    ProgressView()
                } else if !haiku.isEmpty {
                    Text(haiku)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(20)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 100)
                }

                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showHaikuView) {
            HaikuDisplayView(haiku: haiku, isPresented: $showHaikuView)
        }
    }

    func getHaiku(from input: String) {
        isLoading = true
        haiku = ""

        guard let url = URL(string: "https://90ee-107-171-154-236.ngrok-free.app/api/getHaiku") else { return }

        let parameters = ["input": input]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            guard let data = data, error == nil else {
                print("Request failed:", error?.localizedDescription ?? "Unknown error")
                return
            }

            if let decoded = try? JSONDecoder().decode(HaikuRes.self, from: data) {
                DispatchQueue.main.async {
                    self.haiku = decoded.haiku
                    self.showHaikuView = true
                }
            } else {
                print("Failed to decode response")
            }
        }.resume()
    }
}

struct HaikuDisplayView: View {
    let haiku: String
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color(red: 255/255, green: 245/255, blue: 235/255)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()
                
                Text("Your Haiku")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.brown)

                Text(haiku)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .padding(.horizontal)

                Spacer()

                Button(action: {
                    isPresented = false
                }) {
                    Text("Back")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 225/256, green: 120/256, blue: 90/256))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .padding(.horizontal)
                }

                Spacer(minLength: 60)
            }
            .padding()
        }
    }
}

#Preview {
    happypage()
}
