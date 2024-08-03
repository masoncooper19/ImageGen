import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Create sample data for preview
        let newProfile = UserProfile(context: viewContext)
        newProfile.id = UUID()
        newProfile.name = "User"

        let sampleImageData = UIImage(systemName: "photo")!.pngData()!
        for _ in 0..<5 {
            let newImage = SavedImage(context: viewContext)
            newImage.id = UUID()
            newImage.imageData = sampleImageData
            newImage.timestamp = Date()
        }

        do {
            try viewContext.save()
        } catch {
            fatalError("Failed to save preview data: \(error)")
        }

        return result
    }()
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension PersistenceController {
    func saveImage(image: UIImage) {
        let context = container.viewContext
        let newImage = SavedImage(context: context)
        newImage.id = UUID()
        newImage.imageData = image.pngData()
        newImage.timestamp = Date()

        saveContext()
    }

    func deleteImage(_ image: SavedImage) {
        let context = container.viewContext
        context.delete(image)
        saveContext()
    }

    func saveUserProfile(name: String) {
        let context = container.viewContext
        let newProfile = UserProfile(context: context)
        newProfile.id = UUID()
        newProfile.name = name
        
        saveContext()
    }
}
