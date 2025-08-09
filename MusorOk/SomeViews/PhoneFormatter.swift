//
//  PhoneFormatter.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 10.08.2025.
//

import Foundation

struct PhoneFormatter {
    /// Валидные мобильные префиксы KZ после +7 (3 цифры)
    static let kzMobilePrefixes: Set<String> = [
        "700","701","702","705","706","707","708","747",
        "771","775","776","777","778"
    ]

    static func onlyDigits(from s: String) -> String { s.filter(\.isNumber) }

    /// Форматирование ввода (понимает ведущую 8 как +7)
    static func formatKZ(digits raw: String) -> (text: String, nationalDigits: String) {
        var d = raw
        if d.first == "8" { d.removeFirst(); d = "7" + d }
        if d.first == "7" { d.removeFirst() }
        let national = String(d.prefix(10))

        var out = "+7"
        if !national.isEmpty {
            let a = national
            let g1 = a.prefix(3)
            let g2 = a.dropFirst(min(3, a.count)).prefix(max(0, min(3, a.count - 3)))
            let g3 = a.dropFirst(min(6, a.count)).prefix(max(0, min(2, a.count - 6)))
            let g4 = a.dropFirst(min(8, a.count)).prefix(max(0, min(2, a.count - 8)))
            out += " \(g1)"
            if !g2.isEmpty { out += " \(g2)" }
            if !g3.isEmpty { out += " \(g3)" }
            if !g4.isEmpty { out += " \(g4)" }
        }
        return (String(out), national)
    }

    /// Полноценный и валидный номер KZ-мобилы
    static func isValidKZMobile(nationalDigits: String) -> Bool {
        guard nationalDigits.count == 10 else { return false }
        let pfx = String(nationalDigits.prefix(3))
        return kzMobilePrefixes.contains(pfx)
    }
}
