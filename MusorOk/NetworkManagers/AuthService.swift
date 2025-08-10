//
//  AuthService.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 10.08.2025.
//

import Foundation

// Модели
struct LoginRequest: Encodable {
    let password: String
    let phone_number: String   // именно так ожидает бэк
    let role: String           // "user,courier"
}

struct LoginResponse: Decodable {
    let message: String
    let token: String
    let user: Int
}

enum AuthService {
    static func login(phoneNational10: String, password: String, roles: String = "user,courier",
                      completion: @escaping (Result<LoginResponse, APIError>) -> Void) {

        // Бэк ждёт 11-значный номер, начинающийся с 8 (пример: 8706…)
        // У нас в поле хранится национальная часть из 10 цифр (после +7).
        // Формируем «8 + 10 цифр».
        let backendPhone = "8" + phoneNational10

        let body = LoginRequest(password: password, phone_number: backendPhone, role: roles)
        APIClient.shared.post("/auth/login", body: body, completion: completion)
    }
}

