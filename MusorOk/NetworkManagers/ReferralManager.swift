//
//  ReferralManager.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 12.08.2025.
//

import Foundation

enum ReferralManager {
    private static let codeKey = "referral_code_v1"

    /// Бери с бэка, если будет. Пока — генерим и кешируем.
    static var code: String {
        if let c = UserDefaults.standard.string(forKey: codeKey) { return c }
        let new = "MUS" + String(Int.random(in: 100_000...999_999))
        UserDefaults.standard.set(new, forKey: codeKey)
        return new
    }

    static var shareURL: URL {
        // заменишь на свою ссылку
        URL(string: "https://musorok.app/i/\(code)")!
    }

    static var shareMessage: String {
        "Присоединяйся к Мусорок! Мой промокод: \(code). Ссылка: \(shareURL.absoluteString)"
    }
}

