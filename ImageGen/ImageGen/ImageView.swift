import SwiftUI
import UIKit

struct ImageView: View {
    var savedImage: SavedImage
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var showDeleteAlert = false
    @State private var showShareSheet = false
    @State private var uiImage: UIImage?
    @State private var isLoading = true
    @State private var loadError: String?

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
                
                if let uiImage = uiImage {
                    Image(uiImage: uiImage)
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
                
                Text(savedImage.prompt ?? "No prompt available")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                    .padding(.top, 20)

                HStack {
                    Button(action: {
                        if uiImage != nil {
                            // Trigger sheet presentation
                            showShareSheet = true
                        } else {
                            print("Error: No image to share.")
                        }
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(LinearGradient(gradient: Gradient(colors: [.black, .gray]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .edgesIgnoringSafeArea(.all)
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
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
