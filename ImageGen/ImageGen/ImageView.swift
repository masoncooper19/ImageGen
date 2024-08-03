import SwiftUI

struct ImageView: View {
    var savedImage: SavedImage
    
    var body: some View {
        VStack {
            if let data = savedImage.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .padding(.horizontal)
                    .padding(.top, 20)
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
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(gradient: Gradient(colors: [.black, .gray]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
    }
}
