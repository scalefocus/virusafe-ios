//
//  EgnViewModel.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 28.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import TwoWayBondage
import NetworkKit

enum Gender: String, Codable {
    case male = "MALE"
    case female = "FEMALE"
    case notSelected = ""
    case other = "OTHER"
}

protocol TagPresentable {
    var tag: Int { get }
    static func gender(for tag: Int) -> Gender
}

extension Gender: TagPresentable {
    var tag: Int {
        switch self {
            case .male: return 0
            case .female: return 1
            case .notSelected, .other: return 2
        }
    }

    static func gender(for tag: Int) -> Gender {
        switch tag {
            case 0: return .male
            case 1: return .female
            case 2: return .other
            default: return .notSelected
        }
    }
}

//

enum IdentificationNumberType: String, Codable {
    case bulgarianCitizenUCN = "EGN" // uniform civil number (егн)
    case foreignerPIN = "LNCH" // personal identification number (лнч)
    case identificationCard = "PASSPORT" // id card (лк)

    case notSelected
}

protocol SegmentPresentable {
    var segmentIndex: Int { get }
    static func identificationNumberType(for segmentIndex: Int) -> IdentificationNumberType
}

extension IdentificationNumberType: SegmentPresentable {
    var segmentIndex: Int {
        switch self {
            case .foreignerPIN: return 1
            case .identificationCard: return 2
            case .bulgarianCitizenUCN, .notSelected: return 0
        }
    }

    static func identificationNumberType(for segmentIndex: Int) -> IdentificationNumberType {
        switch segmentIndex {
            case 0: return .bulgarianCitizenUCN
            case 1: return .foreignerPIN
            case 2: return .identificationCard
            default: return .notSelected
        }
    }
}

//

enum PersonalInformationValidationError: Error {
    case unknownIdentificationNumberType
    case emptyIdentificationNumber
    case invalidBulgarianCitizenUCN
    case invalidForeignerPIN
    case invalidIdentificationCard
    case emptyAge
    case underMinimumAge
    case overMaximumAge
    case unknownGender
}

//

protocol PersonalInformationViewModelDelegate: class {
    func sendPersonalInformation(_ request: PersonalInformation,
                                 with completion: @escaping SendPersonalInfoCompletion)
    func sendDelayedAnswers(with completion: @escaping SendAnswersCompletion)
}

//

final class PersonalInformationViewModel {

    // MARK: Delegate

    private weak var delegate: PersonalInformationViewModelDelegate?

    // MARK: Injected dependencies

    private let firstLaunchCheckRepository: AppLaunchRepository
    private let personalInformationRepository: PersonalInformationRepository

    // MARK: Helper

    let isInitialFlow: Bool

    // MARK: Binding

    // Communication

    let isSubmitCompleted = Observable<Bool>()
    let requestError = Observable<ApiError>()
    let isLoading = Observable<Bool>()

    // Model

    var age = Observable<String>()
    var gender = Observable<Gender>(.male)
    var preexistingConditions = Observable<String>()
    var identificationNumber = Observable<String>()
    var identificationNumberType = Observable<IdentificationNumberType>(.bulgarianCitizenUCN)

    // Validation

    var validationErrors = Observable<[PersonalInformationValidationError]>()
    var isInputValid = Observable<Bool>(false)

    // MARK: Settings

    private let minimumAge = 14
    private let maximumAge = 110
    private let preexistingConditionsTextLength = 100

    // MARK: Object Lifecycle

    init(firstLaunchCheckRepository: AppLaunchRepository,
         personalInformationRepository: PersonalInformationRepository,
         delegate: PersonalInformationViewModelDelegate) {
        // dependencies
        self.firstLaunchCheckRepository = firstLaunchCheckRepository
        self.personalInformationRepository = personalInformationRepository
        self.delegate = delegate
        // helper
        isInitialFlow = !firstLaunchCheckRepository.isAppLaunchedBefore
    }

    // МАРК: Public Methods
    
    func requestPersonalInformation() {
        // show activity indicator
        isLoading.value = true
        // send request
        personalInformationRepository.requestPersonalInfo { [weak self] result in
            // hide activity indicator
            self?.isLoading.value = false
            // Handle result
            switch result {
                case .success(let personalInformation):
                    // just in case
                    guard let personalInformation = personalInformation else {
                        // Can not parse response
                        self?.requestError.value = .general
                        return
                    }
                    // !!! It is important to be set before age and identificationNumber, because it has some side effects in controller
                    self?.identificationNumberType.value = personalInformation.identificationType ?? .bulgarianCitizenUCN
                    self?.gender.value = personalInformation.gender ?? .male
                    if let age = personalInformation.age {
                        self?.age.value = "\(age)"
                    } else {
                        self?.age.value = nil
                    }
                    self?.preexistingConditions.value = personalInformation.preExistingConditions
                    self?.identificationNumber.value = personalInformation.identificationNumber
                    self?.validate()
                case .failure(let error):
                    self?.requestError.value = error
            }
        }
    }
    
    func sendPersonalInformation() {
        // show activity indicator
        isLoading.value = true
        var ageOrNil: Int? = nil
        if let value = age.value, !value.isEmpty {
            if let age = Int(value), age > 0 {
                ageOrNil = age
            }
        }
        // prepare request
        let request = PersonalInformation(identificationNumber: identificationNumber.value,
                                          identificationType: identificationNumberType.value ?? .notSelected,
                                          phoneNumber: "", // !!! It is not important in the request
                                          age: ageOrNil,
                                          gender: gender.value ?? .notSelected,
                                          preExistingConditions: preexistingConditions.value ?? "")
        // send request
        delegate?.sendPersonalInformation(request) { [weak self] result in
            // if we're gone do nothing
            guard let strongSelf = self else { return }
            // hide activity indicator
            strongSelf.isLoading.value = false
            // handle result
            switch result {
                case .success:
                    // Notify we're ready
                    strongSelf.isSubmitCompleted.value = true
                    // !!! If first launch of the app, mark registration as completed
                    strongSelf.firstLaunchCheckRepository.isAppLaunchedBefore = true
                case .failure(let reason):
                    strongSelf.requestError.value = reason
            }
        }
    }

    func identificationNumberTextFieldWillUpdateText(_ newString: NSString) -> Bool {
        if newString.length == 0 {
            return true
        }

        switch identificationNumberType.value {
            case .bulgarianCitizenUCN:
                return identificationNumberTextFieldWillUpdateText(ucn: newString)
            case .foreignerPIN:
                return identificationNumberTextFieldWillUpdateText(pin: newString)
            case .identificationCard:
                return identificationNumberTextFieldWillUpdateText(cardId: newString)
            default:
                // in case
                return true
        }

        return true
    }

    private func identificationNumberTextFieldWillUpdateText(ucn newString: NSString) -> Bool {
        if newString.length > UCNHelper.maximumPersonalNumberLength {
            return false
        }

        if newString.length > 0 && newString.length < UCNHelper.maximumPersonalNumberLength {
            return true
        }

        // !!! Side effect
        // If lenght is exact try parse it, if valid egn auto populate disabled controls
        if let data = UCNHelper().parse(egn: newString as String) {
            setModelsFromParsedUCNData(data)
        }

        return true
    }

    private func identificationNumberTextFieldWillUpdateText(pin newString: NSString) -> Bool {
        return (newString.length > 0 && newString.length <= PINForeignerHelper.maximumPersonalNumberLength)
    }

    private func identificationNumberTextFieldWillUpdateText(cardId newString: NSString) -> Bool {
        return (newString.length > 0 && newString.length <= IDCardHelper.maximumPersonalNumberLength)
    }

    func ageTextFieldWillUpdateText(_ newString: NSString) -> Bool {
        if newString.length == 0 {
            return true
        }

        let newAge: Int = (newString as NSString).integerValue
        return newAge > 0 && newAge <= maximumAge
    }

    func preexistingConditionsTextFieldWillUpdateText(_ newString: NSString) -> Bool {
        if newString.length == 0 {
            return true
        }

        return newString.length <= preexistingConditionsTextLength
    }

    func validate() {
        let errors = validateInput()
        validationErrors.value = validateInput()
        let importantErrors = errors.filter { $0 != .emptyAge }
        isInputValid.value = (importantErrors.count == 0)
    }

    // MARK: Validations

    private func validateInput() -> [PersonalInformationValidationError] {
        var errors: [PersonalInformationValidationError] = []
        validateAndCatchError(from: validateIdentificationNumber, errors: &errors)
        validateAndCatchError(from: validateAge, errors: &errors)
        validateAndCatchError(from: validateGender, errors: &errors)
        return errors
    }

    private func validateAndCatchError(from validationFunc: () throws -> Void, errors: inout [PersonalInformationValidationError]) {
        do {
            try validationFunc()
        } catch let error as PersonalInformationValidationError {
            errors.append(error)
        } catch {
            // Do nothing
        }
    }

    private func validateGender() throws -> Void {
        guard let sex = gender.value, sex != .notSelected else {
            throw PersonalInformationValidationError.unknownGender
        }
    }

    private func validateAge() throws -> Void {
        guard let text = age.value, let age = Int(text), age > 0 else {
            throw PersonalInformationValidationError.emptyAge
        }

        if age < minimumAge {
            throw PersonalInformationValidationError.underMinimumAge
        }

        if age > maximumAge {
            throw PersonalInformationValidationError.overMaximumAge
        }
    }

    private func validateIdentificationNumber() throws -> Void {
        guard let identificationNumber = identificationNumber.value, !identificationNumber.isEmpty else {
            throw PersonalInformationValidationError.emptyIdentificationNumber
        }

        switch identificationNumberType.value {
            case .bulgarianCitizenUCN:
                try validateUCN(identificationNumber)
            case .foreignerPIN:
                try validatePIN(identificationNumber)
            case .identificationCard:
                try validateID(identificationNumber)
            default:
                throw PersonalInformationValidationError.unknownIdentificationNumberType
        }
    }

    private func validateUCN(_ identificationNumber: String) throws -> Void {
        if !UCNHelper().isValid(egn: identificationNumber) {
            throw PersonalInformationValidationError.invalidBulgarianCitizenUCN
        }
    }

    private func validatePIN(_ identificationNumber: String) throws -> Void  {
        if !PINForeignerHelper().isValid(pin: identificationNumber) {
            throw PersonalInformationValidationError.invalidForeignerPIN
        }
    }

    private func validateID(_ identificationNumber: String) throws -> Void  {
        if !IDCardHelper().isValid(id: identificationNumber) {
            throw PersonalInformationValidationError.invalidIdentificationCard
        }
    }

    // MARK: Helpers

    private func setModelsFromParsedUCNData(_ data: EGNData) {
        if let birthdate = data.birthdate {
            let years = Date.yearsBetween(startDate: birthdate, endDate: Date())
            age.value = "\(years)"
        }

        gender.value = data.sex
    }

}
