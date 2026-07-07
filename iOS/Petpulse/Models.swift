import Foundation

struct PetpulseEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var bpm: Int
    var notes: String
}
