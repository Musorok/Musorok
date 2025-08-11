//
//  UINavigationController+Extension.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 12.08.2025.
//

import UIKit

extension UINavigationController {
    /// Пытается вернуться к первому VC нужного типа в стеке.
    /// Возвращает true, если нашёл и pop-нулся.
    @discardableResult
    func popToViewControllerOfType<T: UIViewController>(_ type: T.Type,
                                                        animated: Bool = true) -> Bool {
        if let target = viewControllers.reversed().first(where: { $0 is T }) {
            popToViewController(target, animated: animated)
            return true
        }
        return false
    }

    func popToOrPush<T: UIViewController>(_ type: T.Type,
                                          makeNew: @autoclosure () -> T,
                                          animated: Bool = true) {
        if !popToViewControllerOfType(type, animated: animated) {
            pushViewController(makeNew(), animated: animated)
        }
    }
}
