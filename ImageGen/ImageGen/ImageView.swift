import SwiftUI
import UIKit
import OpenAIKit

struct ImageView: View {
    var savedImage: SavedImage
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var showDeleteAlert = false
    @State private var showShareSheet = false
    @State private var showActionSheet = false
    @State private var uiImage: UIImage?
    @State private var isLoading = true
    @State private var loadError: String?
    @State private var isGeneratingVariation: Bool = false
    @State private var newImage: UIImage?
    @State private var showSaveButtons = false

    var body: some View {
        NavigationView {
            VStack {
                // Header
                HStack {
                    Text("Image View")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    Spacer()
                }
                .padding(.bottom, 20)

                if let imageToShow = newImage ?? uiImage {
                    Image(uiImage: imageToShow)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .padding(.horizontal)
                        .padding(.top, 50)
                } else {
                    Text("No image available")
                        .foregroundColor(.white)
                        .padding()
                }

                // Prompt Section
                HStack {
                    Text(savedImage.prompt ?? "No prompt available")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.trailing, 8)
                }
                .padding()

                if isGeneratingVariation {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                        .padding(.bottom, 40)
                } else {
                    if !showSaveButtons {
                        Button(action: generateImageVariation) {
                            Text("Generate Variation")
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

                if showSaveButtons {
                    HStack {
                        Button(action: saveGeneratedImage) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                        }
                        .padding(.trailing, 20)
                        
                        Button(action: discardGeneratedImage) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.top, 20)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(LinearGradient(gradient: Gradient(colors: [.black, .gray]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                },
                trailing: Button(action: {
                    showActionSheet = true
                }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            )
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(
                    title: Text("Options"),
                    buttons: [
                        .default(Text("Download")) {
                            downloadImage()
                        },
                        .default(Text("Share")) {
                            showShareSheet = true
                        },
                        .destructive(Text("Delete")) {
                            showDeleteAlert = true
                        },
                        .cancel()
                    ]
                )
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Image"),
                    message: Text("Are you sure you want to delete this image?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteImage()
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showShareSheet) {
                if let uiImage = uiImage {
                    ActivityView(activityItems: [uiImage])
                } else {
                    Text("No image available to share.")
                }
            }
            .onAppear {
                loadImage()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func loadImage() {
        if let data = savedImage.imageData {
            self.uiImage = UIImage(data: data)
            self.isLoading = false
        } else {
            self.loadError = "Failed to load image data."
            self.isLoading = false
        }
    }
    
    private func deleteImage() {
        viewContext.delete(savedImage)
        do {
            try viewContext.save()
        } catch {
            print("Error deleting image: \(error)")
        }
        presentationMode.wrappedValue.dismiss()
    }
    
    private func generateImageVariation() {
        guard let uiImage = uiImage else { return }
        isGeneratingVariation = true
        
        Task {
            do {
                let config = Configuration(
                    organizationId: "ORG_ID",
                    apiKey: "API_KEY"
                )
                let openAI = OpenAI(config)

                let imageVariationParam = try ImageVariationParameters(
                    image: uiImage,
                    resolution: .small,
                    responseFormat: .base64Json
                )
                let variationResponse = try await openAI.generateImageVariations(parameters: imageVariationParam)

                if let base64Image = variationResponse.data.first?.image,
                   let decodedImage = try? openAI.decodeBase64Image(base64Image) {
                    DispatchQueue.main.async {
                        self.newImage = decodedImage
                        self.isGeneratingVariation = false
                        self.showSaveButtons = true
                    }
                } else {
                    print("Failed to decode image.")
                    DispatchQueue.main.async {
                        self.isGeneratingVariation = false
                    }
                }
            } catch {
                print("ERROR - \(error)")
                DispatchQueue.main.async {
                    self.isGeneratingVariation = false
                }
            }
        }
    }

    private func saveGeneratedImage() {
        guard let newImage = newImage else { return }
        uiImage = newImage
        savedImage.imageData = newImage.pngData()
        saveContext()
        showSaveButtons = false
    }

    private func discardGeneratedImage() {
        newImage = nil
        showSaveButtons = false
    }

    private func downloadImage() {
        guard let uiImage = uiImage else { return }
        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
