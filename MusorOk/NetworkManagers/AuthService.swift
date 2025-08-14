//
//  AuthService.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 10.08.2025.
//

//import Foundation
//
//// Модели
//struct LoginRequest: Encodable {
//    let password: String
//    let phone_number: String   // именно так ожидает бэк
//    let role: String           // "user,courier"
//}
//
//struct LoginResponse: Decodable {
//    let message: String
//    let token: String
//    let user: Int
//}
//
//struct RegisterRequest: Encodable {
//    let email: String
//    let name: String
//    let password: String
//    let phone_number: String   // бэк ждёт 11 цифр, начиная с 8
//    let role: String           // "user,courier"
//}
//
//struct RegisterResponse: Decodable {
//    let message: String?
//    let token: String?
//    let user: Int?
//}
//
//enum AuthService {
//    static func login(phoneNational10: String, password: String, roles: String = "user,courier",
//                      completion: @escaping (Result<LoginResponse, APIError>) -> Void) {
//
//        // Бэк ждёт 11-значный номер, начинающийся с 8 (пример: 8706…)
//        // У нас в поле хранится национальная часть из 10 цифр (после +7).
//        // Формируем «8 + 10 цифр».
//        let backendPhone = "8" + phoneNational10
//
//        let body = LoginRequest(password: password, phone_number: backendPhone, role: roles)
//        APIClient.shared.post("/auth/login", body: body, completion: completion)
//    }
//}
//
//extension AuthService {
//    static func register(email: String,
//                         name: String,
//                         password: String,
//                         phoneNational10: String,
//                         roles: String = "user,courier",
//                         completion: @escaping (Result<RegisterResponse, APIError>) -> Void) {
//
//        let backendPhone = "8" + phoneNational10
//        let body = RegisterRequest(email: email,
//                                   name: name,
//                                   password: password,
//                                   phone_number: backendPhone,
//                                   role: roles)
//
//        APIClient.shared.post("/auth/register", body: body, completion: completion)
//    }
//}



import Foundation

struct LoginRequest: Encodable {
    let password: String
    let phone_number: String
    let role: String
}

struct LoginResponse: Decodable {
    let message: String
    let token: String
    let user: Int
}

struct RegisterRequest: Encodable {
    let email: String
    let name: String
    let password: String
    let phone_number: String
    let role: String
}

struct RegisterResponse: Decodable {
    let message: String?
    let token: String?
    let user: Int?
}

enum AuthService {

    // 🔌 Переключатель: true — работаем без бэка; false — реальные запросы
    static var useMock = false

    // MARK: Login
    static func login(phoneNational10: String,
                      password: String,
                      roles: String = "user",
                      completion: @escaping (Result<LoginResponse, APIError>) -> Void) {

        if useMock {
            return mockLogin(phoneNational10: phoneNational10, password: password, roles: roles, completion: completion)
        }

        let ten = phoneNational10.filter { $0.isNumber }
        let backendPhone = "8" + ten
        let body = LoginRequest(password: password, phone_number: backendPhone, role: roles)
        APIClient.shared.post("/auth/login", body: body, completion: completion)
    }

    // MARK: Register
    static func register(email: String,
                         name: String,
                         password: String,
                         phoneNational10: String,
                         roles: String = "user",
                         completion: @escaping (Result<RegisterResponse, APIError>) -> Void) {

        if useMock {
            return mockRegister(email: email, name: name, password: password, phoneNational10: phoneNational10, roles: roles, completion: completion)
        }

        let backendPhone = "8" + phoneNational10
        let body = RegisterRequest(email: email, name: name, password: password, phone_number: backendPhone, role: roles)
        APIClient.shared.post("/auth/register", body: body, completion: completion)
    }
}

// MARK: - MOCKS
private extension AuthService {

    static func mockLogin(phoneNational10: String,
                          password: String,
                          roles: String,
                          completion: @escaping (Result<LoginResponse, APIError>) -> Void) {
        // имитация сети
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            let resp = LoginResponse(
                message: "Вы успешно вошли в систему",
                token: "mock.\(UUID().uuidString)",
                user: 1
            )
            completion(.success(resp))
        }
    }

    static func mockRegister(email: String,
                             name: String,
                             password: String,
                             phoneNational10: String,
                             roles: String,
                             completion: @escaping (Result<RegisterResponse, APIError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let resp = RegisterResponse(
                message: "Регистрация выполнена",
                token: "mock.\(UUID().uuidString)",
                user: 1
            )
            completion(.success(resp))
        }
    }
}

struct DeleteProfileResponse: Decodable { let message: String?; let error: String? }

extension AuthService {
    static func deleteAccount(completion: @escaping (Result<String, APIError>) -> Void) {

        if useMock {
            // мок для разработки
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                completion(.success("OK"))
            }
            return
        }

        APIClient.shared.delete("/profile", requiresAuth: true) { (result: Result<DeleteProfileResponse, APIError>) in
            switch result {
            case .success(let resp):
                completion(.success(resp.message ?? "OK"))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
}
