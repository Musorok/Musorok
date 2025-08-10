//
//  CodeConfirmViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 10.08.2025.
//

import UIKit

final class CodeConfirmViewController: UIViewController, UITextFieldDelegate {

    // входные данные
    private let phone: String          // в формате +7 XXX XXX XX XX (или любой текст для заголовка)
    private let digitsCount: Int = 4   // как на скрине — 4 ячейки
    private let phoneNational10: String

    // колбэки, сюда потом подставишь реальные вызовы бэка
    var onVerify: ((String) -> Void)?      // code -> verify (ожидается успешный токен и т.п.)
    var onResend: (() -> Void)?

    // UI
    private let backButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = .label
        b.backgroundColor = .systemBackground
        b.layer.cornerRadius = 12
        b.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Подтверждение"
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Введите код из СМС."
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 17)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let continueButton: PrimaryButton = {
        let b = PrimaryButton()
        b.setTitle("Продолжить", for: .normal)
        b.isEnabled = false
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private var boxes: [UILabel] = []
    private let hiddenTF: UITextField = {
        let tf = UITextField(frame: .zero)
        tf.keyboardType = .numberPad
        tf.textContentType = .oneTimeCode
        tf.tintColor = .clear
        tf.textColor = .clear
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let resendButton = UIButton(type: .system)
    private var timer: Timer?
    private var secondsLeft = 30

    // MARK: - Init
    
    init(phone: String, phoneNational10: String) {
        self.phone = phone
        self.phoneNational10 = phoneNational10
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Life
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        layout()
        configureResend()
        startTimer()
        hiddenTF.becomeFirstResponder()

        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        hiddenTF.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        
        if onVerify == nil {
            onVerify = { [weak self] code in self?.defaultVerify(code: code) }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async { [weak self] in
            self?.hiddenTF.becomeFirstResponder()
        }
    }

    deinit { timer?.invalidate() }

    // MARK: - Layout
    private func layout() {
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12)
        ])

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // Код: 4 «коробочки»
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        for _ in 0..<digitsCount {
            let l = UILabel()
            l.textAlignment = .center
            l.font = .systemFont(ofSize: 28, weight: .semibold)
            l.backgroundColor = UIColor.secondarySystemFill
            l.textColor = .label
            l.layer.cornerRadius = 12
            l.clipsToBounds = true
            l.heightAnchor.constraint(equalToConstant: 64).isActive = true
            stack.addArrangedSubview(l)
            boxes.append(l)
        }

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])

        // скрытый инпут
        view.addSubview(hiddenTF)
        NSLayoutConstraint.activate([
            hiddenTF.topAnchor.constraint(equalTo: stack.topAnchor),
            hiddenTF.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            hiddenTF.widthAnchor.constraint(equalToConstant: 1),
            hiddenTF.heightAnchor.constraint(equalToConstant: 1)
        ])

        // resend
        resendButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resendButton)
        NSLayoutConstraint.activate([
            resendButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 24),
            resendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        view.addSubview(continueButton)
        NSLayoutConstraint.activate([
            continueButton.topAnchor.constraint(equalTo: resendButton.bottomAnchor, constant: 24),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            continueButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    // MARK: - Actions
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func textChanged() {
        let digits = (hiddenTF.text ?? "").filter(\.isNumber)
        hiddenTF.text = String(digits.prefix(digitsCount))
        updateBoxes(with: hiddenTF.text ?? "")
        continueButton.isEnabled = (digits.count == digitsCount)

        if digits.count == digitsCount {
            verifyCurrentCode()          // авто-проверка
        }
    }

    private func updateBoxes(with code: String) {
        for i in 0..<digitsCount {
            if i < code.count {
                let ch = code[code.index(code.startIndex, offsetBy: i)]
                boxes[i].text = String(ch)
                boxes[i].backgroundColor = .tertiarySystemFill
            } else {
                boxes[i].text = ""
                boxes[i].backgroundColor = .secondarySystemFill
            }
        }
    }

    // MARK: - Resend timer
    private func configureResend() {
        resendButton.setTitleColor(.brandGreen, for: .normal)
        resendButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        resendButton.addTarget(self, action: #selector(resendTapped), for: .touchUpInside)
        resendButton.isEnabled = false
        updateResendTitle()
    }

    private func startTimer() {
        secondsLeft = 30
        resendButton.isEnabled = false
        updateResendTitle()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] t in
            guard let self = self else { return }
            self.secondsLeft -= 1
            if self.secondsLeft <= 0 {
                t.invalidate()
                self.resendButton.isEnabled = true
                self.resendButton.setTitle("Отправить код ещё раз", for: .normal)
            } else {
                self.updateResendTitle()
            }
        })
    }
    
    private func defaultVerify(code: String) {
        guard code == "1234" else {
            // лёгкий шейк и очистка
            let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
            anim.values = [-8, 8, -6, 6, -3, 3, 0]
            anim.duration = 0.3
            view.layer.add(anim, forKey: "shake")
            hiddenTF.text = ""; updateBoxes(with: ""); continueButton.isEnabled = false
            return
        }
        showLoaderAndPushExtra()
    }

    private func showLoaderAndPushExtra() {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        spinner.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            spinner.stopAnimating()
            let vc = RegistrationExtraInfoViewController(phoneNational10: self.phoneNational10)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func updateResendTitle() {
        let mm = String(format: "%02d", secondsLeft / 60)
        let ss = String(format: "%02d", secondsLeft % 60)
        resendButton.setTitle("Отправить код ещё раз \(mm):\(ss)", for: .normal)
    }
    
    private func verifyCurrentCode() {
        let code = (hiddenTF.text ?? "").filter(\.isNumber)
        guard code.count == digitsCount else { return }

        // демо-логика: корректный код — 1234
        guard code == "1234" else {
            let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
            anim.values = [-8, 8, -6, 6, -3, 3, 0]
            anim.duration = 0.3
            view.layer.add(anim, forKey: "shake")
            hiddenTF.text = ""
            updateBoxes(with: "")
            continueButton.isEnabled = false
            return
        }

        // лоадер поверх
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        spinner.startAnimating()
        view.isUserInteractionEnabled = false

        // имитация запроса
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            spinner.stopAnimating()
            spinner.removeFromSuperview()
            self.view.isUserInteractionEnabled = true

            let vc = RegistrationExtraInfoViewController(phoneNational10: self.phoneNational10)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc private func resendTapped() {
        resendButton.isEnabled = false
        onResend?()
        startTimer()
    }
    
    @objc private func continueTapped() {
        verifyCurrentCode()
    }
}

