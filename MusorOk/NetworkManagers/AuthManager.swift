//
//  AuthManager.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 10.08.2025.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    private init() {
        if let data = KeychainStorage.read(account: Self.tokenKey),
           let token = String(data: data, encoding: .utf8) {
            self.token = token
        }
        if let data = KeychainStorage.read(account: Self.userIdKey),
           let s = String(data: data, encoding: .utf8),
           let id = Int(s) {
            self.userId = id
        }
        displayName = UserDefaults.standard.string(forKey: Self.nameKey)
    }

    static let tokenKey = "jwt_token"
    static let userIdKey = "user_id"
    static let nameKey  = "user_display_name"

    private(set) var token: String?
    private(set) var userId: Int?
    private(set) var displayName: String?

    var isAuthorized: Bool { token != nil }

    func setToken(_ token: String, userId: Int) {
        self.token = token
        self.userId = userId
        KeychainStorage.save(Data(token.utf8), account: Self.tokenKey)
        KeychainStorage.save(Data("\(userId)".utf8), account: Self.userIdKey)
        NotificationCenter.default.post(name: .authStateDidChange, object: nil)
    }

    func setDisplayName(_ name: String) {
        displayName = name
        UserDefaults.standard.set(name, forKey: Self.nameKey)
    }

    func logout() {
        token = nil
        userId = nil
        KeychainStorage.delete(account: Self.tokenKey)
        KeychainStorage.delete(account: Self.userIdKey)
        NotificationCenter.default.post(name: .authStateDidChange, object: nil)
    }
}

extension Notification.Name {
    static let authStateDidChange = Notification.Name("authStateDidChange")
}

