//
//  PersonalInformationViewController.swift
//  COVID-19
//
//  Created by Gandi Pirkov on 27.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//
//swiftlint:disable file_length
import UIKit
import SkyFloatingLabelTextField
import IQKeyboardManager

//swiftlint:disable type_body_length
class PersonalInformationViewController: UIViewController, Navigateble {

    // MARK: Navigateble
    weak var navigationDelegate: NavigationDelegate?

    // MARK: Outlets
    @IBOutlet private weak var screenTitleLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var identificationNumberTypeSegmentControl: RoundedSegmentController!
    @IBOutlet private weak var identificationNumberTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var identificationNumberErrorLabel: UILabel!
    @IBOutlet private weak var ageTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var ageErrorLabel: UILabel!
    @IBOutlet private weak var genderLabel: UILabel!
    @IBOutlet private var genderButtons: [UIButton]!
    @IBOutlet private weak var preexistingConditionsTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var privacyPolicyCheckbox: CheckBox!
    @IBOutlet private weak var privacyPolicyInfoButton: UIButton!
    @IBOutlet private weak var privacyPolicyStackView: UIStackView!

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
        // In case checkbox has been selected, but data is not submitted to the server
        viewModel.resetIsAgreeWithPrivacyPolicy()
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

    private func setupUI() {
        title = viewModel.isInitialFlow == true ? "personal_data_title".localized().replacingOccurrences(of: "\\n", with: "\n") :
            "my_personal_data".localized()
        privacyPolicyStackView.isHidden = viewModel.isRegistration

        identificationNumberTextField.placeholder = "identification_number_ucn_segment".localized() + " "
        // By default title will be same as placeholder
        identificationNumberTextField.errorColor = .red

        submitButton.backgroundColor = .healthBlue
        submitButton.setTitle("confirm_label".localized(), for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.setTitleColor(.lightText, for: .disabled)

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

        let text = "i_consent_to_label".localized()
        let link = "data_protection_notice_small_caps_label".localized()
        let title = "\(text) \(link)"
        privacyPolicyInfoButton.setTitle(title, link, for: .normal)
        privacyPolicyInfoButton.titleLabel?.numberOfLines = 0
        privacyPolicyInfoButton.titleLabel?.lineBreakMode = .byWordWrapping

        // can be done on didSet or by setting image alwaysTemplate in asset catalog
        setupIconImageViewTint()

        //Initialize Segment Control
        setupIdentificationNumberTypeSegmentControl()
    }

    private func setupIdentificationNumberTypeSegmentControl() {
        // Segment Titles
        identificationNumberTypeSegmentControl
            .setTitle("identification_number_ucn_segment".localized(),
                      forSegmentAt: IdentificationNumberType.citizenUCN.segmentIndex)
        #if !MACEDONIA
        identificationNumberTypeSegmentControl
            .setTitle("identification_number_pin_segment".localized(),
                      forSegmentAt: IdentificationNumberType.foreignerPIN.segmentIndex)
        #else
        identificationNumberTypeSegmentControl.removeSegment(at: 2,
                                                             animated: false)
        #endif //!MACEDONIA
        identificationNumberTypeSegmentControl
            .setTitle("passport_hint".localized(),
                      forSegmentAt: IdentificationNumberType.identificationCard.segmentIndex)
        // Segment tint
        identificationNumberTypeSegmentControl.tintColor = .healthBlue
    }

    private func setupIconImageViewTint() {
        let image =  UIImage.fontAwesomeIcon(name: .userShield,
                                             style: .light,
                                             textColor: .healthBlue ?? .blue,
                                             size: iconImageView.frame.size)
        iconImageView.image = image
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

            if value {
                self?.submitButton.isEnabled = true
                self?.submitButton.backgroundColor = .healthBlue
            } else {
                self?.submitButton.isEnabled = value
                self?.submitButton.backgroundColor =
                    UIColor.lightGray.withAlphaComponent(0.3)
            }
        }
        viewModel.validationErrors.bind { [weak self] value in
            self?.handleValidationErrors(value)
        }
        viewModel.agreementStatus.bindAndFire { [weak self] value in
            self?.handleAgreementStatus(value)
        }
    }

    private func handleAgreementStatus(_ status: PersonalInformationAgreementStatus) {
        switch status {
        case .accepted:
            privacyPolicyCheckbox.isSelected = true
        case .pending(let newStatus):
            presentPendingChangeAgreementAlertMessage(forNewStatus: newStatus)
        case .update:
            if viewModel.isRegistration {
                viewModel.sendPersonalInformation()
            } else {
                presentUpdatePersonalInformationAlertMessage()
            }
        case .declined:
            privacyPolicyCheckbox.isSelected = false
            clearAll()
        }
    }

    private func clearAll() {
        identificationNumberTextField.text = nil
        ageTextField.text = nil
        preexistingConditionsTextField.text = nil
        identificationNumberErrorLabel.text = nil
        submitButton.isEnabled = false
        submitButton.backgroundColor =
            UIColor.lightGray.withAlphaComponent(0.3)
    }

    private func handleValidationErrors(_ errors: [PersonalInformationValidationError]) {
        ageErrorLabel.text = nil
        identificationNumberErrorLabel.text = nil
        for error in errors {
            switch error {
            case .unknownIdentificationNumberType, .unknownGender:
                // Do nothing (it is not possible to get here)
                break
            case .emptyIdentificationNumber, .invalidBulgarianCitizenUCN,
                 .invalidForeignerPIN, .invalidIdentificationCard, .invalidМacedonianCitizenUCN:
                identificationNumberErrorLabel.text = "field_invalid_format_msg".localized()
            case .emptyAge, .overMaximumAge:
                ageErrorLabel.text = "invalid_age_msg".localized()
            case .underMinimumAge:
                ageErrorLabel.text = "invalid_min_age_msg".localized()
            case .privacyPolicyDeclined:
                presentPrivacyPolicyNotAcceptedErrorAlert()
            }
        }
    }

    // TODO: Refactor - duplicated code
    private func handleNetworkRequestError(_ error: ApiError) {
        switch error {
        case .invalidEgnOrIdNumber:
            let alert = UIAlertController.invalidIdentificationNumberAlert { [weak self] in
                self?.identificationNumberTextField.becomeFirstResponder()
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
        identificationNumberTextField.text = nil

        let isFirstResponder = identificationNumberTextField.isFirstResponder
        identificationNumberTextField.resignFirstResponder()

        identificationNumberTextField.placeholder =
            identificationNumberTypeSegmentControl.titleForSegment(at: identificationNumberType.segmentIndex)

        switch identificationNumberType {
        case .citizenUCN:
            identificationNumberTextField.keyboardType = .numberPad
            setAgeAndGenderControlsEnabled(false)
            #if !MACEDONIA
        case .foreignerPIN:
            identificationNumberTextField.keyboardType = .numberPad
            setAgeAndGenderControlsEnabled(true)
        #endif // !MACEDONIA
        case .identificationCard:
            identificationNumberTextField.keyboardType = .default
            setAgeAndGenderControlsEnabled(true)
        default:
            break // Do nothing
        }

        if isFirstResponder {
            identificationNumberTextField.becomeFirstResponder()
        }
    }

    private func setAgeAndGenderControlsEnabled(_ isEnabled: Bool) {
        setGenderButtonsUserInteraction(isEnabled)
        genderLabel.isEnabled = isEnabled
        ageTextField.isEnabled = isEnabled
    }

    private func setGenderButtonsUserInteraction(_ isEnabled: Bool) {
        for button in genderButtons {
            button.isEnabled = isEnabled
            button.borderColor = isEnabled ? .healthBlue ?? .white : UIColor.lightGray.withAlphaComponent(0.3)
        }
    }

    // MARK: Navigation

    private func navigateToNextViewController() {
        navigationDelegate?.navigateTo(step: viewModel.nextNavigationStep)
    }

    // MARK: Actions

    @IBAction private func didTapSubmitButton(_ sender: Any) {
        viewModel.submitPersonalInformation()
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

    @IBAction private func didTapPrivacyPolicyCheckbox(_ sender: Any) {
        viewModel.toggleIsAgreeWithPrivacyPolicy()
    }

    @IBAction private func didTapPrivacyPolicyInfoButton(_ sender: Any) {
        navigationDelegate?.navigateTo(step: .termsAndConditions(type: .processPersonalData))
    }

    // MARK: Alerts

    // TODO: Refactor to AlertController static factory methods

    private func presentUpdatePersonalInformationAlertMessage() {
        let alert = UIAlertController(title: nil,
                                      message: "popup_update_personal_info_txt".localized(),
                                      preferredStyle: .alert)
        let confirm = UIAlertAction(title: "yes_label".localized(), style: .default) { [weak self] _ in
            self?.viewModel.sendPersonalInformation()
        }
        let cancel = UIAlertAction(title: "no_label".localized(), style: .cancel) { [weak self] _ in
            self?.viewModel.resetIsAgreeWithPrivacyPolicy()
        }
        alert.addAction(confirm)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    private func presentPendingChangeAgreementAlertMessage(forNewStatus status: PersonalInformationAgreementStatus) {
        switch status {
        case .accepted:
            presentConfirmAcceptAgreementAlertMessage()
        case .declined:
            presentConfirmDeclineAgreementAlertMessage()
            return
        default:
            fatalError("Bad status: \(status)")
        }
    }

    private func presentConfirmDeclineAgreementAlertMessage() {
        let alert = UIAlertController(title: nil,
                                      message: "popup_deny_personal_data_access_msg".localized(),
                                      preferredStyle: .alert)
        let confirm = UIAlertAction(title: "yes_label".localized(), style: .default) { [weak self] _ in
            self?.viewModel.declinePrivacyPolicy()
        }
        let cancel = UIAlertAction(title: "no_label".localized(), style: .cancel)
        alert.addAction(confirm)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    private func presentConfirmAcceptAgreementAlertMessage() {
        let alert = UIAlertController(title: nil,
                                      message: "popup_permission_change_txt".localized(),
                                      preferredStyle: .alert)
        let confirm = UIAlertAction(title: "yes_label".localized(), style: .default) { [weak self] _ in
            self?.viewModel.acceptPrivacyPolicy()
        }
        let cancel = UIAlertAction(title: "no_label".localized(), style: .cancel) { [weak self] _ in
            self?.viewModel.resetIsAgreeWithPrivacyPolicy()
        }
        alert.addAction(confirm)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    private func presentPrivacyPolicyNotAcceptedErrorAlert() {
        let alert = UIAlertController(title: "warning_label".localized(),
                                      message: "error_accept_personal_data_access".localized(),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok_label".localized(), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
//swiftlint:enable type_body_length

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

        let newString = textFieldText.replacingCharacters(in: range, with: string)

        if textField == identificationNumberTextField {
            let result = viewModel.identificationNumberTextFieldWillUpdateText(newString)
            return result
        } else if textField == ageTextField {
            let result = viewModel.ageTextFieldWillUpdateText(newString)
            return result
        } else if textField ==  preexistingConditionsTextField {
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

// Build methods for all alerts on the current screen

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

    static var workItems = [AnyHashable: DispatchWorkItem]()

    static var weakTargets = NSPointerArray.weakObjects()

    static func dedupeIdentifierFor(_ object: AnyObject) -> String {
        return "\(Unmanaged.passUnretained(object).toOpaque())." + String(describing: object)
    }

}

extension UISegmentedControl {
    func replaceSegments(segments: [String]) {
        self.removeAllSegments()
        for segment in segments {
            self.insertSegment(withTitle: segment, at: self.numberOfSegments, animated: false)
        }
    }
}
//swiftlint:enable file_length
