import SwiftUI

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: UserProfile.entity(), sortDescriptors: [])
    private var profiles: FetchedResults<UserProfile>
    
    @State private var editingName: Bool = false
    @State private var newUserName: String = ""
    @State private var images: [UIImage] = [] // Placeholder for saved images
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
            }
            .padding(.bottom, 20)
            
            // User Name Section
            HStack {
                if editingName {
                    HStack {
                        TextField("Enter your name", text: $newUserName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding(.trailing, 8)
                        
                        Button(action: saveName) {
                            Text("Save")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                    }
                } else {
                    Text(getUserName())
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.trailing, 8)
                    
                    Button(action: {
                        self.newUserName = getUserName()
                        self.editingName.toggle()
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            
            // Display saved images
            if images.isEmpty {
                Text("No images saved.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                        ForEach(images, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                    }
                    .padding()
                }
            }
            
            Spacer()
        }
        .background(LinearGradient(gradient: Gradient(colors: [.black, .gray]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            loadImages()
        }
    }
    
    private func getUserName() -> String {
        return profiles.first?.name ?? "User"
    }
    
    private func saveName() {
        if let profile = profiles.first {
            profile.name = newUserName
        } else {
            let newProfile = UserProfile(context: viewContext)
            newProfile.name = newUserName
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving name: \(error)")
        }
        
        self.editingName = false
    }
    
    private func loadImages() {
        // Load saved images from Core Data and assign them to the images array
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
