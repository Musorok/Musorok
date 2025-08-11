// ChipsBarView.swift
// MusorOk
//
// Небольшая плашка с чипами: Сегодня · 9:00–21:00 · от 150 ₸ · Оплата картой
// Горизонтальный скролл на всякий случай (если не влезет по ширине)

// ChipsBarView.swift
import UIKit

final class ChipsBarView: UIView {

    struct Item { let text: String; let symbol: String }

    // Акцентный цвет (под сегмент). Применяется ко всем чипсам.
    var accentColor: UIColor = .systemGreen { didSet { applyAccent() } }

    private var itemsCache: [Item] = []

    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.showsHorizontalScrollIndicator = false
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let stack: UIStackView = {
        let st = UIStackView()
        st.axis = .horizontal
        st.spacing = 8
        st.alignment = .center
        st.distribution = .fill
        st.isLayoutMarginsRelativeArrangement = true
        st.layoutMargins = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        st.translatesAutoresizingMaskIntoConstraints = false
        return st
    }()

    // фиксируем минимальную высоту
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 36)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)

        backgroundColor = .clear

        addSubview(scrollView)
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            stack.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(items: [Item]) {
        itemsCache = items
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for item in items {
            stack.addArrangedSubview(makeChip(text: item.text, symbol: item.symbol))
        }
        applyAccent()
    }

    private func makeChip(text: String, symbol: String) -> UIView {
        let container = UIView()
        container.layer.cornerRadius = 10
        container.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.setContentHuggingPriority(.required, for: .horizontal)

        container.addSubview(icon)
        container.addSubview(label)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 32),

            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 14),
            icon.heightAnchor.constraint(equalToConstant: 14),

            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }

    private func applyAccent() {
        // мягкий фон под акцент
        let bg = accentColor.withAlphaComponent(0.14)
        let stroke = accentColor.withAlphaComponent(0.22)
        for v in stack.arrangedSubviews {
            v.backgroundColor = bg
            v.layer.borderWidth = 0.5
            v.layer.borderColor = stroke.cgColor
            // первый subview — иконка, второй — лейбл (как мы создавали)
            (v.subviews.compactMap { $0 as? UIImageView }.first)?.tintColor = accentColor
            (v.subviews.compactMap { $0 as? UILabel }.first)?.textColor = accentColor
        }
    }
}
