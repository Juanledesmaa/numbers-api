//
//  NumbersViewController.swift
//  interview
//
//  Created by juan ledesma on 09/03/2022.
//

import Foundation
import PureLayout
import UIKit

/// Just for practice purposes
private enum AutoLayoutType: String {
    case pureLayout
    case nsLayout
}

class NumbersViewController: UIViewController {

    private var numbersViewModel: NumbersViewModel
    private var textfieldTimer: Timer?
    private var currentAutoLayoutType: AutoLayoutType = .nsLayout

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.keyboardDismissMode = .onDrag
        scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        return scrollView
    }()

    private lazy var rootView: UIView = {
        let view = UIView()
        view.configureForAutoLayout()
        view.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.30, alpha: 1.00)
        return view
    }()

    private lazy var numbersTextField: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.keyboardType = .numberPad
        textfield.backgroundColor = .white
        return textfield
    }()

    private lazy var numbersResultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "LOREM IPSUM DONOR SIT ATMET"
        label.font = UIFont(name: label.font.fontName, size: 30)
        label.numberOfLines = 0
        return label
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Get number Fact!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24)
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor(red: 0.19, green: 0.52, blue: 0.99, alpha: 1.00)
        button.addTarget(self,
                         action: #selector(getNumberFact),
                         for: .touchUpInside)
        return button
    }()

    // MARK: Initialization

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init() {
        fatalError("init() has not been implemented")
    }

    required init(viewModel: NumbersViewModel) {
        self.numbersViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        numbersTextField.delegate = self

        setUpUI()
        setupConstraints()
        setupNotificationCenter()
        setUpTextFieldListeners()
    }

    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func setUpTextFieldListeners() {
//        numbersTextField.addTarget(
//            self,
//            action: #selector(NumbersViewController.textFieldDidChange(_:)),
//            for: .editingChanged
//        )

//        numbersTextField.addTarget(
//            self,
//            action: #selector(NumbersViewController.waitForNumberText(_:)),
//            for: .editingChanged
//        )
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let inputNumber = Int(textField.text ?? "") else { return }

        callNumberFact(with: inputNumber)
    }

    @objc func waitForNumberText(timer: Timer) {
        guard let userInfo = timer.userInfo as? [String: UITextField],
              let inputNumberTextfield = userInfo["textField"],
                let inputNumberText = inputNumberTextfield.text else { return }

            guard let inputNumber = Int(inputNumberText) else { return }
            callNumberFact(with: inputNumber)
    }

    private func setUpUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(rootView)
        rootView.addSubview(confirmButton)
        rootView.addSubview(numbersTextField)
        rootView.addSubview(numbersResultLabel)

    }

    private func setupConstraints() {
        switch currentAutoLayoutType {
        case .pureLayout:
            configureConstraintsWithPureLayout()
        case .nsLayout:
            configureConstraintsWithNSLayout()
        }
    }

    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[
            UIResponder.keyboardFrameEndUserInfoKey
        ] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            let bottomInset = (keyboardViewEndFrame.height - view.safeAreaInsets.bottom) + 140
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        }

        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }

    @objc func keyboardWillHide(notification _: NSNotification) {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }

    @objc func getNumberFact() {
        view.endEditing(true)

        guard let inputNumber = Int(numbersTextField.text ?? "") else { return }

        numbersViewModel.getNumberFactData(with: inputNumber) { [weak self] result in
            guard let result = result else { return }//Error message

            DispatchQueue.main.async {
                self?.numbersResultLabel.text = result
                self?.numbersResultLabel.isHidden = false
            }
        }
    }

    private func callNumberFact(with number: Int) {
        numbersViewModel.getNumberFactData(with: number) { [weak self] result in
            guard let result = result else { return }//Error message

            DispatchQueue.main.async {
                self?.numbersResultLabel.text = result
                self?.numbersResultLabel.isHidden = false
            }
        }
    }

}

extension NumbersViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String
    ) -> Bool {
        textfieldTimer?.invalidate()
        textfieldTimer = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(NumbersViewController.waitForNumberText),
            userInfo: ["textField": textField],
            repeats: false)
            return true
    }

}

// MARK: - Pure Layout constraints methods
extension NumbersViewController {
    private func configureConstraintsWithPureLayout() {
        scrollView.autoPinEdgesToSuperviewEdges()
        rootView.autoPinEdgesToSuperviewEdges()
        rootView.autoCenterInSuperview()

        let heightConstraint = rootView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        heightConstraint.priority = UILayoutPriority(rawValue: 250)
        heightConstraint.isActive = true

        // Confirm Button
        confirmButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 30)
        confirmButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 30)
        confirmButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 40)
        confirmButton.autoSetDimension(.height, toSize: 60)

        // Numbers Textfield
        numbersTextField.autoPinEdge(toSuperviewEdge: .leading, withInset: 30)
        numbersTextField.autoPinEdge(toSuperviewEdge: .trailing, withInset: 30)
        numbersTextField.autoPinEdge(.bottom, to: .top, of: confirmButton, withOffset: -30)
        numbersTextField.autoSetDimension(.height, toSize: 60)

        // Result label
        numbersResultLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 30)
        numbersResultLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 30)
        numbersResultLabel.autoPinEdge(.bottom, to: .top, of: numbersTextField, withOffset: -30)
        numbersResultLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 30)
    }
}

// MARK: - NS Layout constraints methods
extension NumbersViewController {
    private func configureConstraintsWithNSLayout() {

        // ScrollView
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // RootView
        let rootViewHeightConstraint = rootView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        rootViewHeightConstraint.priority = UILayoutPriority(rawValue: 250)

        NSLayoutConstraint.activate([
            rootView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            rootView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            rootView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            rootView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            rootView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            rootView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            rootViewHeightConstraint
        ])

        // Confirm Button

        NSLayoutConstraint.activate([
            confirmButton.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 30),
            confirmButton.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -30),
            confirmButton.bottomAnchor.constraint(equalTo: rootView.bottomAnchor, constant: -30),
            confirmButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        // Numbers textfield

        NSLayoutConstraint.activate([
            numbersTextField.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 30),
            numbersTextField.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -30),
            numbersTextField.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -30),
            numbersTextField.heightAnchor.constraint(equalToConstant: 60)
        ])

        // Result Label

        NSLayoutConstraint.activate([
            numbersResultLabel.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 30),
            numbersResultLabel.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -30),
            numbersResultLabel.bottomAnchor.constraint(equalTo: numbersTextField.topAnchor, constant: -30),
            numbersResultLabel.topAnchor.constraint(equalTo: rootView.topAnchor, constant: 60)
        ])
    }
}
