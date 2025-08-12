//
//  AddressStore.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 12.08.2025.
//

import Foundation

struct SavedAddress: Codable, Equatable, Identifiable {
    let id: UUID
    var label: String            // произвольное имя ("Дом", "Офис")
    var line: String             // форматированная строка адреса
    var apartment: String?
    var floor: String?
    var entrance: String?
    var intercom: String?
    var dontCall: Bool

    init(id: UUID = UUID(),
         label: String,
         line: String,
         apartment: String? = nil,
         floor: String? = nil,
         entrance: String? = nil,
         intercom: String? = nil,
         dontCall: Bool = false) {
        self.id = id
        self.label = label
        self.line = line
        self.apartment = apartment
        self.floor = floor
        self.entrance = entrance
        self.intercom = intercom
        self.dontCall = dontCall
    }
}

enum AddressStore {
    private static let key = "saved_addresses_v1"

    static func load() -> [SavedAddress] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([SavedAddress].self, from: data)) ?? []
    }

    static func save(_ items: [SavedAddress]) {
        let data = try? JSONEncoder().encode(items)
        UserDefaults.standard.set(data, forKey: key)
    }

    static func add(_ item: SavedAddress) {
        var all = load()
        all.insert(item, at: 0)
        save(all)
    }

    static func remove(id: UUID) {
        var all = load()
        all.removeAll { $0.id == id }
        save(all)
    }
}
