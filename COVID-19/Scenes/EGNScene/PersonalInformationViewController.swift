//
//  PersonalInformationViewController.swift
//  COVID-19
//
//  Created by Gandi Pirkov on 27.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import IQKeyboardManager



//

class PersonalInformationViewController: UIViewController, Navigateble {

    // MARK: Navigateble

    weak var navigationDelegate: NavigationDelegate?
    
    // MARK: Outlets
    
    @IBOutlet private weak var screenTitleLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var identificationNumberTypeSegmentControl: UISegmentedControl!
    @IBOutlet private weak var identificationNumberTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var identificationNumberErrorLabel: UILabel!
    @IBOutlet private weak var ageTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var ageErrorLabel: UILabel!
    @IBOutlet private weak var genderLabel: UILabel!
    @IBOutlet private var genderButtons: [UIButton]!
    @IBOutlet private weak var preexistingConditionsTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var submitButton: UIButton!

    // MARK: View Model
    
    var viewModel: PersonalInformationViewModel!

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // style and localize
        setupUI()
        // React on view model events
        setupBindings()
        // Load any previously saved data from the server
        viewModel.requestPersonalInformation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 80
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 10
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // close keyboard on tap
        view.endEditing(true)
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // Try disable paste
        if identificationNumberTextField.isFirstResponder || ageTextField.isFirstResponder || preexistingConditionsTextField.isFirstResponder {
            DispatchQueue.main.async {
                UIMenuController.shared.setMenuVisible(false, animated: false)
            }
        }

        return super.canPerformAction(action, withSender: sender)
    }

    // MARK: Setup UI
    
    private func setupUI() {
        title = viewModel.isInitialFlow == true ? "personal_data_title".localized().replacingOccurrences(of: "\\n", with: "\n") :
                                                  "my_personal_data".localized()

        identificationNumberTextField.placeholder = "identification_number_ucn_segment".localized() + " "
        // By default title will be same as placeholder
        identificationNumberTextField.errorColor = .red
        
        submitButton.backgroundColor = .healthBlue
        submitButton.setTitle("confirm_label".localized(), for: .normal)

        screenTitleLabel.text = "personal_data_title".localized()
        identificationNumberTextField.placeholder = "identification_number_hint".localized()
        ageTextField.placeholder = "age_hint".localized()
        genderLabel.text = "gender_hint".localized()
        preexistingConditionsTextField.placeholder = "chronical_conditions_hint".localized()

        for button in genderButtons {
            if button.tag == Gender.female.tag {
                button.setTitle("gender_female".localized(), for: .normal)
            } else if button.tag == Gender.male.tag {
                button.setTitle("gender_male".localized(), for: .normal)
            }
        }

        // can be done on didSet or by setting image alwaysTemplate in asset catalog
        setupIconImageViewTint()

        identificationNumberTypeSegmentControl
            .setTitle("identification_number_ucn_segment".localized(),
                      forSegmentAt: IdentificationNumberType.bulgarianCitizenUCN.segmentIndex)
        identificationNumberTypeSegmentControl
            .setTitle("identification_number_pin_segment".localized(),
                      forSegmentAt: IdentificationNumberType.foreignerPIN.segmentIndex)
        identificationNumberTypeSegmentControl
            .setTitle("identification_number_id_segment".localized(),
                      forSegmentAt: IdentificationNumberType.identificationCard.segmentIndex)
        identificationNumberTypeSegmentControl.tintColor = .healthBlue
    }
    
    private func setupIconImageViewTint() {
        let userShieldIcon = #imageLiteral(resourceName: "user-shield").withRenderingMode(.alwaysTemplate)
        iconImageView.image = userShieldIcon
        iconImageView.tintColor = .healthBlue
    }

    // MARK: Bind

    private func setupBindings() {
        // go to next screen
        viewModel.isSubmitCompleted.bind { [weak self] result in
            guard result else { return }
            self?.navigateToNextViewController()
        }

        // show activity indicator and disable controls if needed
        viewModel.isLoading.bind { [weak self] shouldShowLoadingIndicator in
            self?.handleLoadingStateChanged(shouldShowLoadingIndicator)
        }

        // show communication error
        viewModel.requestError.bind { [weak self] error in
            self?.handleNetworkRequestError(error)
        }

        // bind UI Components
        ageTextField.bind(with: viewModel.age)
        preexistingConditionsTextField.bind(with: viewModel.preexistingConditions)
        identificationNumberTextField.bind(with: viewModel.identificationNumber)

        viewModel.gender.bindAndFire { [weak self] value in
            self?.handleGenderChanged(value)
        }
        viewModel.identificationNumberType.bindAndFire { [weak self] value in
            self?.handleIdentificationNumberTypeChanged(value)
        }
        viewModel.isInputValid.bindAndFire { [weak self] value in
            if value {
                self?.identificationNumberErrorLabel.text = nil
                self?.ageErrorLabel.text = nil
            }
            self?.submitButton.isUserInteractionEnabled = value
        }
        viewModel.validationErrors.bind { [weak self] value in
            self?.handleValidationErrors(value)
        }
    }

    private func handleValidationErrors(_ errors: [PersonalInformationValidationError]) {
        ageErrorLabel.text = nil
        identificationNumberErrorLabel.text = nil
        for error in errors {
            switch error {
                case .unknownIdentificationNumberType, .unknownGender:
                    // Do nothing (it is not possible to get here)
                    break
                case .emptyIdentificationNumber, .invalidBulgarianCitizenUCN, .invalidForeignerPIN, .invalidIdentificationCard:
                    identificationNumberErrorLabel.text = "field_invalid_format_msg".localized()
                case .emptyAge, .overMaximumAge:
                    ageErrorLabel.text = "invalid_age_msg".localized()
                case .underMinimumAge:
                    ageErrorLabel.text = "invalid_min_age_msg".localized()
            }
        }
    }

    // TODO: Refactor - duplicated code
    private func handleNetworkRequestError(_ error: ApiError) {
        switch error {
            case .invalidEgnOrIdNumber:
                let alert = UIAlertController.invalidIdentificationNumberAlert() { [weak self] in
                    self?.identificationNumberTextField.becomeFirstResponder()
                }
                present(alert, animated: true, completion: nil)
            case .invalidToken:
                let alert = UIAlertController.invalidTokenAlert() { [weak self] in
                    self?.navigationDelegate?.navigateTo(step: .register)
                }
                present(alert, animated: true, completion: nil)
            case .tooManyRequests(let reapeatAfter):
                let alert = UIAlertController.rateLimitExceededAlert(repeatAfterSeconds: reapeatAfter)
                present(alert, animated: true, completion: nil)
            case .server, .general:
                showToast(message: "generic_error_msg".localized())
        }
    }

    private func handleLoadingStateChanged(_ shouldShowLoadingIndicator: Bool) {
        if shouldShowLoadingIndicator {
            LoadingIndicatorManager.startActivityIndicator(.gray, in: view)
        } else {
            LoadingIndicatorManager.stopActivityIndicator(in: view)
        }
    }

    private func handleGenderChanged(_ gender: Gender) {
        for button in genderButtons {
            if button.tag == gender.tag {
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = .healthBlue
            } else {
                button.backgroundColor = .white
                button.setTitleColor(.healthBlue, for: .normal)
            }
        }
    }

    private func handleIdentificationNumberTypeChanged(_ identificationNumberType: IdentificationNumberType) {
        identificationNumberTypeSegmentControl.selectedSegmentIndex = identificationNumberType.segmentIndex

        viewModel.identificationNumber.value = nil
//        viewModel.age.value = nil
        identificationNumberTextField.text = nil
//        ageTextField.text = nil
//
        let isFirstResponder = identificationNumberTextField.isFirstResponder
        identificationNumberTextField.resignFirstResponder()

        identificationNumberTextField.placeholder =
            identificationNumberTypeSegmentControl.titleForSegment(at: identificationNumberType.segmentIndex)

        switch identificationNumberType {
            case .bulgarianCitizenUCN:
                identificationNumberTextField.keyboardType = .numberPad
                setGenderButtonsUserInteraction(false)
                ageTextField.isUserInteractionEnabled = false
            case .foreignerPIN:
                identificationNumberTextField.keyboardType = .numberPad
                setGenderButtonsUserInteraction(true)
                ageTextField.isUserInteractionEnabled = true
            case .identificationCard:
                identificationNumberTextField.keyboardType = .default
                setGenderButtonsUserInteraction(true)
                ageTextField.isUserInteractionEnabled = true
            default:
                break // Do nothing
        }

        if isFirstResponder {
            identificationNumberTextField.becomeFirstResponder()
        }
    }

    private func setGenderButtonsUserInteraction(_ isEnabled: Bool) {
        for button in genderButtons {
            button.isUserInteractionEnabled = isEnabled
        }
    }

    // MARK: Navigation

    private func navigateToNextViewController() {
        navigationDelegate?.navigateTo(step: viewModel.isInitialFlow ? .healthStatus : .home)
    }
    
    // MARK: Actions
    
    @IBAction private func didTapSubmitButton(_ sender: Any) {
        viewModel.sendPersonalInformation()
    }
    
    @IBAction private func didTapGenderButton(_ sender: UIButton) {
        viewModel.gender.value = Gender.gender(for: sender.tag)
        viewModel.validate()
    }

    @IBAction private func didChangePersonalIdentifierType(_ sender: UISegmentedControl) {
        viewModel.identificationNumberType.value =
            IdentificationNumberType.identificationNumberType(for: sender.selectedSegmentIndex)
        viewModel.validate()
    }

    @IBAction private func textFieldDidChange(_ textField: UITextField) {
//        // !!! Wait for binding
//        DispatchQueue.main.async {
//            self.viewModel.validate()
//        }
    }

}

// MARK: ToastViewPresentable

extension PersonalInformationViewController: ToastViewPresentable {}

// MARK: UITextFieldDelegate

extension PersonalInformationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        defer {
            // !!! Wait for binding
            DispatchQueue.main.asyncDeduped(target: self, after: 0.3) { [weak self] in
                self?.viewModel.validate()
            }
        }
        guard let textFieldText = textField.text as NSString? else {
            return false
        }
        let newString = textFieldText.replacingCharacters(in: range, with: string) as NSString
        
        if textField == identificationNumberTextField {
            let result = viewModel.identificationNumberTextFieldWillUpdateText(newString)
            return result
        } else if textField == ageTextField {
            let result = viewModel.ageTextFieldWillUpdateText(newString)
            return result
        } else if textField ==  preexistingConditionsTextField{
            let result = viewModel.preexistingConditionsTextFieldWillUpdateText(newString)
            return result
        }
        
        return true
    }
}

// MARK: Helpers

extension Date {
    static func yearsBetween(startDate: Date, endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year],
                                                 from: startDate,
                                                 to: endDate)
        return components.year ?? 0
    }
}

// Build methods for all allerts on the current screen

extension UIAlertController {
    static func invalidIdentificationNumberAlert(_ actionHandler: (() -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: nil,
                                      message: "invalid_egn_msg".localized(),
                                      preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "ok_label".localized(), style: .default) { _ in
                actionHandler?()
            }
        )
        return alert
    }
}

extension UIAlertController {
    static func invalidTokenAlert(_ actionHandler: (() -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: nil,
                                      message: "redirect_to_registration_msg".localized(),
                                      preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "ok_label".localized(), style: .default) { _ in
                actionHandler?()
            }
        )
        return alert
    }
}

// MARK: Vendor

extension DispatchQueue {

    /**
     - parameters:
     - target: Object used as the sentinel for de-duplication.
     - delay: The time window for de-duplication to occur
     - work: The work item to be invoked on the queue.
     Performs work only once for the given target, given the time window. The last added work closure
     is the work that will finally execute.
     Note: This is currently only safe to call from the main thread.
     Example usage:
     ```
     DispatchQueue.main.asyncDeduped(target: self, after: 1.0) { [weak self] in
     self?.doTheWork()
     }
     ```
     */
    public func asyncDeduped(target: AnyObject, after delay: TimeInterval, execute work: @escaping @convention(block) () -> Void) {
        let dedupeIdentifier = DispatchQueue.dedupeIdentifierFor(target)
        if let existingWorkItem = DispatchQueue.workItems.removeValue(forKey: dedupeIdentifier) {
            existingWorkItem.cancel()
            NSLog("Deduped work item: \(dedupeIdentifier)")
        }
        let workItem = DispatchWorkItem {
            DispatchQueue.workItems.removeValue(forKey: dedupeIdentifier)

            for ptr in DispatchQueue.weakTargets.allObjects {
                if dedupeIdentifier == DispatchQueue.dedupeIdentifierFor(ptr as AnyObject) {
                    work()
                    NSLog("Ran work item: \(dedupeIdentifier)")
                    break
                }
            }
        }

        DispatchQueue.workItems[dedupeIdentifier] = workItem
        DispatchQueue.weakTargets.addPointer(Unmanaged.passUnretained(target).toOpaque())

        asyncAfter(deadline: .now() + delay, execute: workItem)
    }

}

// MARK: - Static Properties for De-Duping
private extension DispatchQueue {

    static var workItems = [AnyHashable : DispatchWorkItem]()

    static var weakTargets = NSPointerArray.weakObjects()

    static func dedupeIdentifierFor(_ object: AnyObject) -> String {
        return "\(Unmanaged.passUnretained(object).toOpaque())." + String(describing: object)
    }

}
