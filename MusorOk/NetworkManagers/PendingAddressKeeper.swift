//
//  PendingAddressKeeper.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 17.08.2025.
//

import Foundation

enum PendingAddressKeeper {
    private(set) static var pending: SavedAddress?

    static func set(_ item: SavedAddress?) {
        pending = item
    }

    /// Вызываем при успехе оплаты — переносит отложенный адрес в постоянное хранилище
    static func flushIfNeeded() {
        if let item = pending {
            AddressStore.add(item)
            pending = nil
        }
    }

    /// Если пользователь отменил оплату/вышел
    static func clear() { pending = nil }
}

