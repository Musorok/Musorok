//
//  CenterSnappingFlowLayout.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 12.08.2025.
//

import UIKit

import UIKit

final class CenterSnappingFlowLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposed: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let cv = collectionView else { return proposed }
        let isH = (scrollDirection == .horizontal)

        // центр коллекции (в координатах контента) на предлагаемом оффсете
        let bounds = cv.bounds
        let mid = isH ? bounds.midX : bounds.midY
        let targetCenter = (isH ? proposed.x : proposed.y) + mid

        // смотрим широкий прямоугольник вокруг целевого оффсета (чтобы точно найти ближайшую ячейку)
        let search = CGRect(
            x: (isH ? proposed.x : 0) - bounds.width/2,
            y: (isH ? 0 : proposed.y) - bounds.height/2,
            width: bounds.width * 2,
            height: bounds.height * 2
        )

        guard let attrs = super.layoutAttributesForElements(in: search), !attrs.isEmpty else {
            return proposed
        }

        var candidate: UICollectionViewLayoutAttributes?
        for a in attrs where a.representedElementCategory == .cell {
            let c = isH ? a.center.x : a.center.y
            if candidate == nil ||
                abs(c - targetCenter) < abs((isH ? candidate!.center.x : candidate!.center.y) - targetCenter) {
                candidate = a
            }
        }
        guard let final = candidate else { return proposed }

        // оффсет так, чтобы final оказался по центру
        let newX = isH ? final.center.x - mid : proposed.x
        let newY = isH ? proposed.y : final.center.y - mid

        // чуть-чуть приглушим «перелёт» при быстрых свайпах
        if isH {
            let minX = -cv.contentInset.left
            let maxX = cv.contentSize.width - bounds.width + cv.contentInset.right
            return CGPoint(x: max(minX, min(newX, maxX)), y: newY)
        } else {
            let minY = -cv.contentInset.top
            let maxY = cv.contentSize.height - bounds.height + cv.contentInset.bottom
            return CGPoint(x: newX, y: max(minY, min(newY, maxY)))
        }
    }
}


// MARK: - Пилюльная ячейка
final class PillCell: UICollectionViewCell {
    private let label = UILabel()
    var title: String = "" { didSet { label.text = title } }
    var isOn: Bool = false {
        didSet {
            contentView.backgroundColor = isOn ? UIColor.systemGray5 : UIColor.systemGray6
            label.textColor = isOn ? .label : .secondaryLabel
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        contentView.layer.cornerRadius = 22
        contentView.backgroundColor = .systemGray6
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}
