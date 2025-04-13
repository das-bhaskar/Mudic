//
//  SadPage.swift
//  Mudic
//
//  Created by Bhaskar Das on 2025-04-13.
//


import SwiftUI

struct SadPage: View {
    @State private var currentJoke: String = "Loading a silly joke..."
    @State private var isLoading: Bool = false
    @GestureState private var dragOffset = CGSize.zero
    @State private var cardOffset = CGSize.zero

    var body: some View {
        ZStack {
            Color(red: 230/255, green: 240/255, blue: 255/255)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Swipe your sadness away 😢➡️😂")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()

                ZStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                    } else {
                        Text(currentJoke)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 250)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(radius: 6)
                            .offset(x: cardOffset.width + dragOffset.width)
                            .rotationEffect(.degrees(Double(cardOffset.width / 20)))
                            .gesture(
                                DragGesture()
                                    .updating($dragOffset, body: { value, state, _ in
                                        state = value.translation
                                    })
                                    .onEnded { value in
                                        if abs(value.translation.width) > 100 {
                                            // Trigger new joke on swipe
                                            withAnimation(.easeInOut) {
                                                cardOffset = CGSize(width: value.translation.width > 0 ? 1000 : -1000, height: 0)
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                cardOffset = .zero
                                                fetchJoke()
                                            }
                                        } else {
                                            withAnimation {
                                                cardOffset = .zero
                                            }
                                        }
                                    }
                            )
                            .animation(.spring(), value: cardOffset)
                    }
                }
                .padding()

                Text("Swipe left or right for more 🤪")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .onAppear {
            fetchJoke()
        }
    }

    // Fetch a new joke from your Gemini-powered API
    func fetchJoke() {
        guard let url = URL(string: "https://90ee-107-171-154-236.ngrok-free.app/api/joke") else {
            currentJoke = "Oops! Invalid joke server URL."
            return
        }

        isLoading = true

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["text": ""] as [String: String]) // optional if needed

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    currentJoke = "Error: \(error.localizedDescription)"
                    return
                }
                if let data = data {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let joke = json["joke"] as? String {
                        currentJoke = joke
                    } else {
                        currentJoke = "Couldn't understand the joke. Try swiping again!"
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    SadPage()
}
