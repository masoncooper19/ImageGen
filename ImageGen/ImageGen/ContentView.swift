import SwiftUI
import OpenAIKit

struct ContentView: View {
    @State private var image: UIImage? = nil
    @State private var isLoading = false
    @State private var prompt = ""
    @State private var showProfile = false
    @State private var showImageActions = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Title
                HStack {
                    Text("ImageGen")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .padding(.trailing, 20)
                    }
                }
                .padding(.top, 50)
                
                // Display image or placeholder
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .padding()

                    HStack {
                        Button(action: saveImage) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                        }
                        .padding(.trailing, 20)
                        
                        Button(action: deleteImage) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.top, 20)
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
                
                Spacer()
                
                // TextField for prompt input
                TextField("Enter prompt...", text: $prompt)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding()
                
                // Loading indicator or generate button
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                        .padding(.bottom, 40)
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
                    .padding(.bottom, 40)
                }
            }
            .background(LinearGradient(gradient: Gradient(colors: [.black, .gray]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    func generateImage() {
        isLoading = true
        Task {
            do {
                let config = Configuration(
                    organizationId: "ORG_ID",
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
    
    func saveImage() {
        guard let image = image else { return }
        
        // Save image to Core Data
        let newImage = SavedImage(context: PersistenceController.shared.container.viewContext)
        newImage.id = UUID()
        newImage.imageData = image.pngData()
        newImage.timestamp = Date()
        newImage.prompt = prompt
        
        do {
            try PersistenceController.shared.container.viewContext.save()
            print("Image saved successfully.")
        } catch {
            print("Error saving image: \(error)")
        }
        
        // Reset the image
        self.image = nil
    }
    
    func deleteImage() {
        // Reset the image
        self.image = nil
        print("Image deleted.")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
