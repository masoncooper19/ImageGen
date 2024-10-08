import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [])
    private var profiles: FetchedResults<UserProfile>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \SavedImage.timestamp, ascending: false)])
    private var savedImages: FetchedResults<SavedImage>
    
    @State private var editingName: Bool = false
    @State private var newUserName: String = ""
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("")
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
                            .textFieldStyle(PlainTextFieldStyle())
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
            if savedImages.isEmpty {
                Text("No images saved.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                        ForEach(savedImages) { savedImage in
                            if let data = savedImage.imageData, let uiImage = UIImage(data: data) {
                                NavigationLink(destination: ImageView(savedImage: savedImage)) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 100)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            
            Spacer()
        }
        .background(LinearGradient(gradient: Gradient(colors: [.black, .gray]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let profile = profiles.first {
                self.newUserName = profile.name ?? "User"
            } else {
                let newProfile = UserProfile(context: viewContext)
                newProfile.id = UUID()
                newProfile.name = "User"
                saveContext()
            }
        }
        .navigationBarItems(
            leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
        )
        .navigationBarBackButtonHidden(true)
    }
    
    private func saveName() {
        if let profile = profiles.first {
            profile.name = newUserName
            saveContext()
            editingName = false
        }
    }
    
    private func getUserName() -> String {
        profiles.first?.name ?? "User"
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
