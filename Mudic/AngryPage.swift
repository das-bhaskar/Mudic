import SwiftUI

struct AngryPage: View {
    @State private var ventText: String = ""
    @State private var hasVented: Bool = false
    @State private var apiResponse: String = ""
    @State private var navigateBack: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 1.0, green: 230/255, blue: 230/255)
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    if !hasVented {
                        Text("Let it out. Vent freely.")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding()

                        TextEditor(text: $ventText)
                            .padding()
                            .frame(height: 200)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(radius: 5)

                        Button(action: {
                            withAnimation {
                                hasVented = true
                            }
                            vent()
                        }) {
                            Text("Release!")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 0.85, green: 0.5, blue: 0.5)) // darker pastel red
                                .cornerRadius(15)
                                .padding(.horizontal)
                                .shadow(radius: 5)
                        }

                    } else {
                        VStack(spacing: 20) {
                            Text("Breathe in... Breathe out 🌬️")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            Image(systemName: "wind")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue.opacity(0.7))
                                .padding()

                            if !apiResponse.isEmpty {
                                Text(apiResponse)
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(12)
                                    .shadow(radius: 4)
                                    .padding(.horizontal)
                            }

                            // I am still fuming button
                            Button(action: {
                                hasVented = false
                                ventText = ""
                                apiResponse = ""
                            }) {
                                Text("I am still fuming 😤")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 0.7, green: 0.4, blue: 0.4)) // darker pastel red
                                    .cornerRadius(15)
                                    .padding(.horizontal)
                            }

                            // NavigationLink to go back
                            NavigationLink(destination: apiuiviewtest(), isActive: $navigateBack) {
                                EmptyView()
                            }

                            // I feel better now button
                            Button(action: {
                                navigateBack = true
                            }) {
                                Text("I feel better now")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 0.6, green: 0.5, blue: 0.5)) // darker pastel of background
                                    .cornerRadius(15)
                                    .padding(.horizontal)
                            }
                        }
                        .transition(.opacity)
                    }
                }
                .padding()
            }
        }
    }

    func vent() {
        guard let url = URL(string: "https://90ee-107-171-154-236.ngrok-free.app/api/vent") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["text": ventText]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    apiResponse = "Error: \(error.localizedDescription)"
                }
                return
            }

            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let message = json["message"] as? String {
                        DispatchQueue.main.async {
                            apiResponse = message
                        }
                    } else {
                        DispatchQueue.main.async {
                            apiResponse = "Received an unexpected response."
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        apiResponse = "Failed to parse response."
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    AngryPage()
}
