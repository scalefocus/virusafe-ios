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

enum Gender: String, Codable, CaseIterable {
    case male = "MALE"
    case female = "FEMALE"
    case notSelected = ""
    case other = "OTHER"

    var tag: Int {
        switch self {
        case .male:
            return 0
        case .female:
            return 1
        case .notSelected, .other:
            return 2
        }
    }
}

class PersonalInformationViewController: UIViewController, Navigateble {

    // MARK: Navigateble

    weak var navigationDelegate: NavigationDelegate?
    
    // MARK: Outlets
    
    @IBOutlet private weak var egnTitleLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var egnTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var egnErrorLabel: UILabel!

    @IBOutlet weak var genderLable: UILabel!
    @IBOutlet weak var ageTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var egnSubmitButton: UIButton!
    @IBOutlet private var genderButtons: [UIButton]!
    @IBOutlet weak var preexistingConditionsTextField: SkyFloatingLabelTextField!
    
    // MARK: Settings
    private let preexistingConditionsTextLength = 100 // Same as android
//    private let minimumPersonalNumberLength = 9
    private let maximumPersonalNumberLength = 10
    private let maximumAge = 110
    
    // MARK: View Model
    
    var viewModel: PersonalInformationViewModel!

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.start()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupUI()
        
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 80
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 10
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if egnTextField.isFirstResponder || ageTextField.isFirstResponder || preexistingConditionsTextField.isFirstResponder {
            DispatchQueue.main.async {
                UIMenuController.shared.setMenuVisible(false, animated: false)
            }
        }

        return super.canPerformAction(action, withSender: sender)
    }

    // MARK: Setup UI
    
    private func setupUI() {
        setupIconImageViewTint()
        setupEgnTextField()

        title = viewModel.isInitialFlow == true ? "personal_data_title".localized().replacingOccurrences(of: "\\n", with: "\n") :
                                                  "my_personal_data".localized()
        
        egnSubmitButton.backgroundColor = .healthBlue
        egnTitleLabel.text = "personal_data_title".localized()
        egnTextField.placeholder = "identification_number_hint".localized()
        ageTextField.placeholder = "age_hint".localized()
        genderLable.text = "gender_hint".localized()
        preexistingConditionsTextField.placeholder = "chronical_conditions_hint".localized()
        egnSubmitButton.setTitle("confirm_label".localized(), for: .normal)
        genderButtons[Gender.female.tag].setTitle("gender_female".localized(), for: .normal)
        genderButtons[Gender.male.tag].setTitle("gender_male".localized(), for: .normal)
    }
    
    private func setupIconImageViewTint() {
        let userShieldIcon = #imageLiteral(resourceName: "user-shield").withRenderingMode(.alwaysTemplate)
        iconImageView.image = userShieldIcon
        iconImageView.tintColor = .healthBlue
    }
    
    private func setupEgnTextField() {
        egnTextField.placeholder = "identification_number_hint".localized() + " "
        // By default title will be same as placeholder
        egnTextField.errorColor = .red
    }

    // MARK: Bind

    private func setupBindings() {
        viewModel.isSendPersonalInformationCompleted.bind { [weak self] result in
            self?.navigateToNextViewController()
        }
        
        viewModel.shouldShowLoadingIndicator.bind { [weak self] shouldShowLoadingIndicator in
            guard let strongSelf = self else { return }
            if shouldShowLoadingIndicator {
                LoadingIndicatorManager.startActivityIndicator(.gray, in: strongSelf.view)
            } else {
                LoadingIndicatorManager.stopActivityIndicator(in: strongSelf.view)
            }
        }

        // TODO: Refactor - duplicated code
        viewModel.requestError.bind { [weak self] error in
            switch error {
                case .invalidEgnOrIdNumber:
                    let alert = UIAlertController(title: nil,
                                                  message: "invalid_egn_msg".localized(),
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok_label".localized(), style: .default))
                    self?.present(alert, animated: true, completion: nil)
                case .invalidToken:
                    let alert = UIAlertController(title: "redirect_to_registration_msg".localized(),
                                                  message: "redirect_to_registration_msg".localized(),
                                                  preferredStyle: .alert)
                    alert.addAction(
                        UIAlertAction(title: "ok_label".localized(), style: .default) { action in
                            self?.navigationDelegate?.navigateTo(step: .register)
                        }
                    )
                    self?.present(alert, animated: true, completion: nil)
                case .tooManyRequests(let reapeatAfter):
                    let alert = UIAlertController.rateLimitExceededAlert(repeatAfterSeconds: reapeatAfter)
                    self?.present(alert, animated: true, completion: nil)
                case .server, .general:
                    self?.showToast(message: "generic_error_msg".localized())
            }
        }
        
        ageTextField.bind(with: viewModel.age)
        preexistingConditionsTextField.bind(with: viewModel.preexistingConditions)
        egnTextField.bind(with: viewModel.identificationNumber)
        viewModel.gender.bindAndFire { [weak self] value in
            guard let strongSelf = self else {
                return
            }
            
            for button in strongSelf.genderButtons {
                button.backgroundColor = .white
                button.setTitleColor(.healthBlue, for: .normal)
            }
            
            strongSelf.genderButtons[value.tag].setTitleColor(.white, for: .normal)
            strongSelf.genderButtons[value.tag].backgroundColor = .healthBlue
        }
  
        // fired only on success
//        viewModel.isSendAnswersCompleted.bind { [weak self] result in
//            self?.navigateToNextViewController()
//        }
    }

    // MARK: Navigation

    private func navigateToNextViewController() {
        navigationDelegate?.navigateTo(step: viewModel.isInitialFlow ? .healthStatus : .home)
    }
    
    // MARK: Actions
    
    @IBAction private func didTapSubmitButton(_ sender: Any) {
        guard let egn = egnTextField.text, !egn.isEmpty && EGNHelper().isValid(egn: egn) else {
            let alert = UIAlertController(title: nil,
                                          message: "invalid_egn_msg".localized(),
                                          preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(title: "ok_label".localized(), style: .default) { action in
                    self.egnTextField.becomeFirstResponder()
                }
            )
            present(alert, animated: true, completion: nil)
            return
        }

        guard let text = ageTextField.text, let age = Int(text), age >= 16 else {
            let alert = UIAlertController(title: nil,
                                          message: "invalid_min_age_msg".localized(),
                                          preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(title: "ok_label".localized(), style: .default) { action in
                    self.egnTextField.becomeFirstResponder()
                }
            )
            present(alert, animated: true, completion: nil)
            return
        }

        viewModel.didTapPersonalNumberAuthorization(with: egnTextField.text ?? "")
    }
    
    @IBAction private func didTapGenderButton(_ sender: UIButton) {
        viewModel.gender.value = Gender.allCases.first(where: { $0.tag == sender.tag }) ?? Gender.notSelected
    }
    
}

// MARK: ToastViewPresentable

extension PersonalInformationViewController: ToastViewPresentable {}

// MARK: UITextFieldDelegate

extension PersonalInformationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text as NSString? else { return false }
        let newString = textFieldText.replacingCharacters(in: range, with: string) as NSString
        
        if textField == egnTextField {
            submitButtonLocked(false)

            // Validation
            guard newString.length > 0 else {
                egnErrorLabel.text = nil
                return true
            }

            if newString.length < maximumPersonalNumberLength {
                egnErrorLabel.text = "field_invalid_format_msg".localized()
                return true
            }

            egnErrorLabel.text = nil

            if newString.length > maximumPersonalNumberLength {
                submitButtonLocked(true)
                return false
            }

            // Parse if valid egn
            if let data = EGNHelper().parse(egn: newString as String) {
                if let birthdate = data.birthdate {
                    let years = Date.yearsBetween(startDate: birthdate, endDate: Date())
                    // ??? Check if years is empty
                    viewModel.age.value = "\(years)"
                }

                viewModel.gender.value = data.sex
                
                submitButtonLocked(true)
            } else {
                egnErrorLabel.text = "field_invalid_format_msg".localized()
            }

            return newString.length <= maximumPersonalNumberLength
        } else if textField == ageTextField {
            let newAge:Int = (newString as NSString).integerValue
            return newAge >= 0 && newAge <= maximumAge
        } else if textField ==  preexistingConditionsTextField{
            return newString.length <= preexistingConditionsTextLength
        }
        
        return true
    }
    
    func submitButtonLocked(_ locked: Bool) {
        // TODO: Make it more reactive
        egnSubmitButton.isEnabled = locked
    }
}

extension Date {
    static func yearsBetween(startDate: Date, endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year],
                                                 from: startDate,
                                                 to: endDate)
        return components.year ?? 0
    }
}
