import SwiftUI
import OpenAIKit

struct ContentView: View {
    @State private var image: UIImage? = nil
    @State private var isLoading = false
    @State private var prompt = ""
    
    var body: some View {
        VStack {
            // Title
            Text("ImageGen")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 40)
                .padding(.bottom, 20)
            
            // Display image or placeholder
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .padding(.horizontal)
            } else {
                VStack {
                    Rectangle()
                        .foregroundColor(Color.gray.opacity(0.2))
                        .frame(height: 300)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .overlay(
                            VStack {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("No Image")
                                    .foregroundColor(.gray)
                            }
                        )
                }
                .padding(.horizontal)
            }
            
            // TextField for prompt input
            TextField("Enter prompt...", text: $prompt)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
            
            Spacer()
            
            // Loading indicator or generate button
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding()
            } else {
                Button(action: generateImage) {
                    Text("Generate Image")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [.black, .gray]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
    }
    
    func generateImage() {
        isLoading = true
        Task {
            do {
                let config = Configuration(
                    organizationId: "ORG_KEY",
                    apiKey: "API_KEY"
                )
                let openAi = OpenAI(config)
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
