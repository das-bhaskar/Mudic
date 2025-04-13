import SwiftUI

struct TestAPIView: View {
    @State private var userInput: String = ""
    @State private var mood: String = ""
    @State private var message: String = ""
    @State private var rgb: String = ""
    @State private var isLoading: Bool = false
    
    let apiUrl = "http://127.0.0.1:5000/api/analyze"

    var body: some View {
        VStack {
            TextField("Enter your mood description", text: $userInput)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 300)
            
            Button(action: {
                self.fetchData()
            }) {
                Text("Analyze Mood")
                    .font(.title)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()

            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }

            if !mood.isEmpty {
                Text("Mood: \(mood)")
                    .font(.headline)
                    .padding()

                Text("Message: \(message)")
                    .font(.body)
                    .padding()

                Text("Color (RGB): \(rgb)")
                    .font(.body)
                    .padding()
                    .foregroundColor(Color(rgbColor: rgb))
            }
        }
        .padding()
    }

    func fetchData() {
        guard let url = URL(string: apiUrl) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["text": userInput]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
        
        isLoading = true

        URLSession.shared.dataTask(with: request) { data, response, error in
            isLoading = false
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        DispatchQueue.main.async {
                            self.mood = jsonResponse["mood"] as? String ?? ""
                            self.message = jsonResponse["message"] as? String ?? ""
                            self.rgb = jsonResponse["rgb"] as? String ?? ""
                        }
                    }
                } catch {
                    print("Error parsing response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}

extension Color {
    init(rgbColor: String) {
        let cleanedRgb = rgbColor.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
        let components = cleanedRgb.split(separator: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        
        if components.count == 3 {
            self.init(red: components[0] / 255, green: components[1] / 255, blue: components[2] / 255)
        } else {
            self.init(red: 0, green: 0, blue: 0) // Default to black if RGB is invalid
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TestAPIView()
    }
}
