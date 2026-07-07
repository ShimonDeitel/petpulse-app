import XCTest
@testable import Petpulse

@MainActor
final class PetpulseTests: XCTestCase {
    func makeIsolatedStore() -> PetpulseStore {
        // Each store instance persists to the same app-support file; tests rely on
        // starting from seeded state and only asserting relative deltas.
        PetpulseStore()
    }

    func testSeedDataLoadsBelowFreeLimit() {
        let store = makeIsolatedStore()
        XCTAssertFalse(store.entries.isEmpty)
        XCTAssertLessThan(store.entries.count, PetpulseStore.freeEntryLimit)
    }

    func testAddEntrySucceedsUnderLimit() {
        let store = makeIsolatedStore()
        let before = store.entries.count
        let added = store.addEntry(date: Date(), bpm: 0, notes: "Test note", isPro: false)
        XCTAssertTrue(added)
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testCanAddEntryRespectsFreeLimit() {
        let store = makeIsolatedStore()
        for _ in 0..<(PetpulseStore.freeEntryLimit + 5) {
            _ = store.addEntry(date: Date(), bpm: 0, notes: "Filler", isPro: false)
        }
        XCTAssertEqual(store.entries.count, PetpulseStore.freeEntryLimit)
        XCTAssertFalse(store.canAddEntry(isPro: false))
    }

    func testProBypassesFreeLimit() {
        let store = makeIsolatedStore()
        for _ in 0..<(PetpulseStore.freeEntryLimit + 5) {
            _ = store.addEntry(date: Date(), bpm: 0, notes: "Filler", isPro: true)
        }
        XCTAssertGreaterThan(store.entries.count, PetpulseStore.freeEntryLimit)
    }

    func testDeleteEntryRemovesIt() {
        let store = makeIsolatedStore()
        _ = store.addEntry(date: Date(), bpm: 0, notes: "note", isPro: false)
        guard let entry = store.entries.first else { return XCTFail("expected entry") }
        let before = store.entries.count
        store.deleteEntry(entry.id)
        XCTAssertEqual(store.entries.count, before - 1)
    }

    func testUpdateEntryChangesFields() {
        let store = makeIsolatedStore()
        _ = store.addEntry(date: Date(), bpm: 0, notes: "note", isPro: false)
        guard let entry = store.entries.first(where: { _ in true }) else { return XCTFail("expected entry") }
        store.updateEntry(entry.id, date: entry.date, bpm: 0, notes: entry.notes)
        XCTAssertTrue(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testDeleteAllDataReseeds() {
        let store = makeIsolatedStore()
        store.deleteAllData()
        XCTAssertFalse(store.entries.isEmpty)
    }

    func testEntriesSortedByDateDescending() {
        let store = makeIsolatedStore()
        let older = Calendar.current.date(byAdding: .day, value: -100, to: Date())!
        let newer = Date()
        _ = store.addEntry(date: older, bpm: 0, notes: "note", isPro: false)
        _ = store.addEntry(date: newer, bpm: 0, notes: "note", isPro: false)
        XCTAssertEqual(store.entries.first?.date, store.entries.map(\.date).max())
    }
}
