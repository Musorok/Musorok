//
//  APIClient.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 10.08.2025.
//

import Foundation

enum APIError: Error {
    case network(Error)
    case server(message: String, code: Int)
    case decoding
    case unknown
}

private struct ServerErrorDTO: Decodable { let message: String? }

final class APIClient {
    static let shared = APIClient()

    // проверь, что со схемой:
    private let baseURL = URL(string: "http://37.140.243.60:1232")!

    private let session: URLSession = {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 20
        cfg.timeoutIntervalForResource = 30
        return URLSession(configuration: cfg)
    }()

    func post<T: Encodable, R: Decodable>(_ path: String,
                                          body: T,
                                          completion: @escaping (Result<R, APIError>) -> Void) {
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        let data = try? JSONEncoder().encode(body)
        req.httpBody = data

        // 🔎 лог для отладки
        #if DEBUG
        if let data = data, let json = String(data: data, encoding: .utf8) {
            print("➡️ POST \(url.absoluteString)\nBODY: \(json)")
        }
        #endif

        session.dataTask(with: req) { data, resp, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(.network(error))) }
                return
            }
            guard let http = resp as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(.unknown)) }
                return
            }

            let status = http.statusCode
            #if DEBUG
            let bodyStr = data.flatMap { String(data: $0, encoding: .utf8) } ?? "<empty>"
            print("⬅️ \(status) \(url.absoluteString)\nBODY: \(bodyStr)")
            #endif

            // не-2xx -> достанем message
            guard (200...299).contains(status) else {
                var msg = "Неизвестная ошибка"
                if let data = data {
                    if let dto = try? JSONDecoder().decode(ServerErrorDTO.self, from: data),
                       let m = dto.message, !m.isEmpty {
                        msg = m
                    } else if let s = String(data: data, encoding: .utf8), !s.isEmpty {
                        msg = s
                    }
                }
                DispatchQueue.main.async { completion(.failure(.server(message: msg, code: status))) }
                return
            }

            // успех
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.unknown)) }
                return
            }
            do {
                let obj = try JSONDecoder().decode(R.self, from: data)
                DispatchQueue.main.async { completion(.success(obj)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.decoding)) }
            }
        }.resume()
    }
}

struct MessageResponse: Decodable { let message: String?; let error: String? }

extension APIClient {
    func delete<R: Decodable>(_ path: String,
                              requiresAuth: Bool = true,
                              completion: @escaping (Result<R, APIError>) -> Void) {
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth, let token = AuthManager.shared.token, !token.isEmpty {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        session.dataTask(with: req) { data, resp, error in
            if let error = error { return DispatchQueue.main.async { completion(.failure(.network(error))) } }
            guard let http = resp as? HTTPURLResponse else {
                return DispatchQueue.main.async { completion(.failure(.unknown)) }
            }

            #if DEBUG
            let bodyStr = data.flatMap { String(data: $0, encoding: .utf8) } ?? "<empty>"
            print("⬅️ \(http.statusCode) DELETE \(url.absoluteString)\nBODY: \(bodyStr)")
            #endif

            guard (200...299).contains(http.statusCode) else {
                var msg = "Неизвестная ошибка"
                if let data = data {
                    if let dto = try? JSONDecoder().decode(MessageResponse.self, from: data),
                       let m = dto.message ?? dto.error, !m.isEmpty { msg = m }
                    else if let s = String(data: data, encoding: .utf8), !s.isEmpty { msg = s }
                }
                return DispatchQueue.main.async { completion(.failure(.server(message: msg, code: http.statusCode))) }
            }

            guard let data = data else {
                return DispatchQueue.main.async { completion(.failure(.unknown)) }
            }
            do {
                let obj = try JSONDecoder().decode(R.self, from: data)
                DispatchQueue.main.async { completion(.success(obj)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.decoding)) }
            }
        }.resume()
    }
}

extension APIClient {
    func put<T: Encodable, R: Decodable>(_ path: String,
                                         body: T,
                                         requiresAuth: Bool = true,
                                         completion: @escaping (Result<R, APIError>) -> Void) {
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        if requiresAuth, let token = AuthManager.shared.token, !token.isEmpty {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let payload = try? JSONEncoder().encode(body)
        req.httpBody = payload

        #if DEBUG
        if let payload, let json = String(data: payload, encoding: .utf8) {
            print("➡️ PUT \(url.absoluteString)\nBODY: \(json)")
        }
        #endif

        session.dataTask(with: req) { data, resp, error in
            if let error = error {
                return DispatchQueue.main.async { completion(.failure(.network(error))) }
            }
            guard let http = resp as? HTTPURLResponse else {
                return DispatchQueue.main.async { completion(.failure(.unknown)) }
            }

            #if DEBUG
            let bodyStr = data.flatMap { String(data: $0, encoding: .utf8) } ?? "<empty>"
            print("⬅️ \(http.statusCode) \(url.absoluteString)\nBODY: \(bodyStr)")
            #endif

            guard (200...299).contains(http.statusCode) else {
                var msg = "Неизвестная ошибка"
                if let data = data {
                    if let dto = try? JSONDecoder().decode(MessageResponse.self, from: data),
                       let m = dto.message ?? dto.error, !m.isEmpty { msg = m }
                    else if let s = String(data: data, encoding: .utf8), !s.isEmpty { msg = s }
                }
                return DispatchQueue.main.async { completion(.failure(.server(message: msg, code: http.statusCode))) }
            }

            guard let data = data else {
                return DispatchQueue.main.async { completion(.failure(.unknown)) }
            }
            do {
                let obj = try JSONDecoder().decode(R.self, from: data)
                DispatchQueue.main.async { completion(.success(obj)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.decoding)) }
            }
        }.resume()
    }
}


