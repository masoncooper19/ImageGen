import SwiftUI
import OpenAIKit

struct ContentView: View {
    @State private var image: UIImage? = nil
    @State private var isLoading = false
    @State private var prompt = "A futuristic city in space"
    
    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            } else {
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(height: 300)
                    .overlay(Text("No Image").foregroundColor(.white))
            }
            
            TextField("Enter prompt", text: $prompt)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if isLoading {
                ProgressView()
            } else {
                Button(action: generateImage) {
                    Text("Generate Image")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }
    
    func generateImage() {
        isLoading = true
        Task {
            do {
                let openAi = OpenAI(apiKey: "YOUR_API_KEY")
                let imageParam = ImageParameters(
                    prompt: prompt,
                    resolution: .large,
                    responseFormat: .base64Json
                )
                let result = try await openAi.createImage(parameters: imageParam)
                let b64Image = result.data[0].image
                let decodedImage = try openAi.decodeBase64Image(b64Image)
                self.image = decodedImage
            } catch {
                print("Error generating image: \(error)")
            }
            isLoading = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
