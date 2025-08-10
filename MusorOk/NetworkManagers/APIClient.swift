//
//  APIClient.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 10.08.2025.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case transport(Error)
    case server(status: Int, message: String?)
    case decoding

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Неверный URL"
        case .transport(let e): return e.localizedDescription
        case .server(_, let msg): return msg ?? "Ошибка сервера"
        case .decoding: return "Ошибка обработки ответа"
        }
    }
}

struct APIClient {
    static let shared = APIClient()
    private init() {}

    // ! HTTP, поэтому убедись что в Info.plist ATS разрешён (у тебя уже стоит NSAllowsArbitraryLoads)
    private let base = URL(string: "http://37.140.243.60:1232")!

    func post<B: Encodable, R: Decodable>(
        _ path: String,
        body: B,
        headers: [String: String] = ["Content-Type": "application/json", "accept": "application/json"],
        completion: @escaping (Result<R, APIError>) -> Void
    ) {
        guard let url = URL(string: path, relativeTo: base) else {
            completion(.failure(.invalidURL)); return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }
        if let token = AuthManager.shared.token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        do {
            req.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(.transport(error))); return
        }

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let err = err { return completion(.failure(.transport(err))) }
            guard let http = resp as? HTTPURLResponse, let data = data else {
                return completion(.failure(.server(status: -1, message: "Нет ответа")))
            }
            let status = http.statusCode

            // Попробуем декодировать успех
            if (200..<300).contains(status) {
                do {
                    let val = try JSONDecoder().decode(R.self, from: data)
                    completion(.success(val))
                } catch {
                    completion(.failure(.decoding))
                }
                return
            }

            // Ошибка сервера — попробуем вытащить message
            let msg = (try? JSONDecoder().decode(ServerMessage.self, from: data))?.message
            completion(.failure(.server(status: status, message: msg)))
        }.resume()
    }
}

struct ServerMessage: Decodable { let message: String }

