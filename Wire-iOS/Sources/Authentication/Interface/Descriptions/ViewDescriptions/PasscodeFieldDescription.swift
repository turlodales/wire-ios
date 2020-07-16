
// Wire
// Copyright (C) 2020 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import Foundation
import UIKit

protocol PasscodeTextFieldDelegate: class {
    func textFieldDidUpdateText(_ textField: PasscodeTextField)
    func textFieldDidSubmitWithValidationError(_ textField: PasscodeTextField)
    func textField(_ textField: PasscodeTextField, didConfirmCredentials credentials: (String))
}


final class PasscodeFieldDescription: ValueSubmission {
    let textField = PasscodeTextField()
    
    var prefilledEmail: String?
    var acceptsInput: Bool = true
    
    var valueSubmitted: ValueSubmitted?
    var valueValidated: ValueValidated?    
}

extension PasscodeFieldDescription: ViewDescriptor, PasscodeTextFieldDelegate {
    
    
    func create() -> UIView {
        textField.passwordField.kind = .password(isNew: true)
        textField.delegate = self
        
        return textField
    }
    
    func textFieldDidUpdateText(_ textField: PasscodeTextField) {
        // Reset the error message when the user changes the text and we use deferred validation
        valueValidated?(nil)
        textField.passwordField.hideGuidanceDot()
    }
    
    func textField(_ textField: PasscodeTextField, didConfirmCredentials credentials: (String)) {
        valueSubmitted?(credentials)
    }
    
    func textFieldDidSubmitWithValidationError(_ textField: PasscodeTextField) {
        if let passwordError = textField.passwordValidationError {
            textField.passwordField.showGuidanceDot()
            valueValidated?(.error(passwordError, showVisualFeedback: true))
        }
    }
}

final class PasscodeTextField: UIView, MagicTappable {
    
    lazy var passwordField: AccessoryTextField = {
        let textField = AccessoryTextField(kind: .passcode)

        textField.overrideButtonIcon = .eye //TODO: eye with slash, change icon when pressed
        
        return textField
    }()
    

    
    private let contentStack = UIStackView()
    
    weak var delegate: PasscodeTextFieldDelegate?
    
    private(set) var passwordValidationError: TextFieldValidator.ValidationError? = .tooShort(kind: .email)
    
    // MARK: - Helpers
    
    var colorSchemeVariant: ColorSchemeVariant = .light {
        didSet {
            passwordField.colorSchemeVariant = colorSchemeVariant
        }
    }
    
    var isPasswordEmpty: Bool {
        return passwordField.input.isEmpty
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureSubviews()
        configureConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSubviews() {
        //TODO: clean up with EmailPasswordTextField
        contentStack.axis = .vertical
        contentStack.spacing = 0
        contentStack.alignment = .fill
        contentStack.distribution = .fill
        addSubview(contentStack)
        
        passwordField.delegate = self
        passwordField.textFieldValidationDelegate = self
        passwordField.placeholder = "password.placeholder".localized(uppercased: true)
        //        passwordField.bindConfirmationButton(to: emailField)
        passwordField.addTarget(self, action: #selector(textInputDidChange), for: .editingChanged)
        passwordField.confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        passwordField.colorSchemeVariant = colorSchemeVariant
        
        passwordField.enableConfirmButton = { [weak self] in
            self?.isPasswordEmpty == false
        }
        
        contentStack.addArrangedSubview(passwordField)
        
        //MARK: labels
        
        let texts = ["❌ 8 characters long",
                     "❌ 1 lowercase letter",
                     "❌ 1 capital letter",
                     "❌ 1 special character"]
        
        texts.forEach() {
            let label = UILabel()
            
            //TODO: clean up with EmailLinkVerificationMainView
            label.font = AuthenticationStepController.subtextFont
            label.textColor = UIColor.Team.subtitleColor
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            
            label.text = $0
            contentStack.addArrangedSubview(label)
        }
    }
    
    private func configureConstraints() {
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // dimensions
            passwordField.heightAnchor.constraint(equalToConstant: 56), ///TODO: const in EmailPasswordTextField
            
            // contentStack
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.topAnchor.constraint(equalTo: topAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    // MARK: - Appearance
    
    func setTextColor(_ color: UIColor) {
        passwordField.textColor = color
    }
    
    func setBackgroundColor(_ color: UIColor) {
        passwordField.backgroundColor = color
    }
    
    // MARK: - Responder
    
    override var isFirstResponder: Bool {
        return passwordField.isFirstResponder
    }
    
    override var canBecomeFirstResponder: Bool {
        return logicalFirstResponder.canBecomeFirstResponder
    }
    
    override func becomeFirstResponder() -> Bool {
        return logicalFirstResponder.becomeFirstResponder()
    }
    
    override var canResignFirstResponder: Bool {
        return passwordField.canResignFirstResponder
    }
    
    @discardableResult override func resignFirstResponder() -> Bool {
        if passwordField.isFirstResponder {
            return passwordField.resignFirstResponder()
        }
        
        return false
    }
    
    /// Returns the text field that should be used to become first responder.
    private var logicalFirstResponder: UITextField {
        return passwordField
    }
    
    // MARK: - Submission
    
    @objc
    private func confirmButtonTapped() {
        guard passwordValidationError == nil else {
            delegate?.textFieldDidSubmitWithValidationError(self)
            return
        }
        
        delegate?.textField(self, didConfirmCredentials: (passwordField.input))
    }
    
    func performMagicTap() -> Bool {
        guard passwordField.isInputValid else {
            return false
        }
        
        confirmButtonTapped()
        return true
    }
    
    @objc
    private func textInputDidChange(sender: UITextField) {
        if sender == passwordField {
            passwordField.validateInput()
        }
        
        delegate?.textFieldDidUpdateText(self)
    }
    
}

extension PasscodeTextField: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordField {
            passwordField.validateInput()
            confirmButtonTapped()
        }
        
        return true
    }
    
}

extension PasscodeTextField: TextFieldValidationDelegate {
    func validationUpdated(sender: UITextField, error: TextFieldValidator.ValidationError?) {
        passwordValidationError = error
    }
}
