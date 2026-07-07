import SwiftUI

@main
struct PetpulseApp: App {
    @StateObject private var store = PetpulseStore()
    @StateObject private var purchases = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(purchases)
                .tint(Theme.primary)
        }
    }
}
