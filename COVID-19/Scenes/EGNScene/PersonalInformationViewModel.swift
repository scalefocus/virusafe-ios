//
//  EgnViewModel.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 28.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

//swiftlint:disable file_length
import Foundation
import TwoWayBondage
import NetworkKit

enum Gender: String, Codable {
    case male = "MALE"
    case female = "FEMALE"
    case notSelected = ""
    case other = "OTHER"

    var genderType: String {
        return self.rawValue
    }
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

enum IdentificationNumberType: String, Codable {
    #if !MACEDONIA
    case citizenUCN = "EGN" // uniform civil number (егн)
    case foreignerPIN = "LNCH" // personal identification number (лнч)
    #else // !MACEDONIA
    case citizenUCN = "EMBG"
    #endif // !MACEDONIA
    case identificationCard = "PASSPORT" // id card (лк)
    case notSelected

    var identificationType: String {
        return self.rawValue
    }
}

protocol SegmentPresentable {
    var segmentIndex: Int { get }
    static func identificationNumberType(for segmentIndex: Int) -> IdentificationNumberType
}

extension IdentificationNumberType: SegmentPresentable {
    var segmentIndex: Int {
        switch self {
            #if MACEDONIA
        case .identificationCard: return 1
            #else // MACEDONIA
        case .foreignerPIN: return 1
        case .identificationCard: return 2
        #endif // MACEDONIA
        case .citizenUCN, .notSelected: return 0
        }
    }

    static func identificationNumberType(for segmentIndex: Int) -> IdentificationNumberType {
        switch segmentIndex {
        case 0: return .citizenUCN
            #if MACEDONIA
        case 1: return .identificationCard
            #else // MACEDONIA
        case 1: return .foreignerPIN
        case 2: return .identificationCard
        #endif // MACEDONIA
        default: return .notSelected
        }
    }
}

enum PersonalInformationValidationError: Error {
    case unknownIdentificationNumberType
    case emptyIdentificationNumber
    case invalidBulgarianCitizenUCN, invalidМacedonianCitizenUCN
    case invalidForeignerPIN
    case invalidIdentificationCard
    case emptyAge
    case underMinimumAge
    case overMaximumAge
    case unknownGender
}

final class PersonalInformationViewModel {

    // MARK: Injected dependencies

    private let firstLaunchCheckRepository: AppLaunchRepository
    private let personalInformationRepository: PersonalInformationRepository

    // MARK: Helpers

    private lazy var ucnHelper: UCNHelper = {
        #if MACEDONIA
        return MKUCNHelper()
        #else
        return BGUCNHelper()
        #endif
    }()

    // UI

    var isInitialFlow: Bool {
        return !firstLaunchCheckRepository.isAppLaunchedBefore
    }

    // Navigation

    private (set) var shouldNavigateNextToHealthStatus: Bool

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
    var identificationNumberType = Observable<IdentificationNumberType>(.citizenUCN)

    // Validation

    var validationErrors = Observable<[PersonalInformationValidationError]>()
    var isInputValid = Observable<Bool>(false)

    // MARK: Settings

    private let minimumAge = 14
    private let maximumAge = 110
    private let preexistingConditionsTextLength = 100

    // MARK: Object Lifecycle

    init(firstLaunchCheckRepository: AppLaunchRepository, // Used to change title
        personalInformationRepository: PersonalInformationRepository,
        shouldNavigateNextToHealthStatus: Bool) {
        // dependencies
        self.firstLaunchCheckRepository = firstLaunchCheckRepository
        self.personalInformationRepository = personalInformationRepository
        // passed data
        self.shouldNavigateNextToHealthStatus = shouldNavigateNextToHealthStatus
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
                self?.identificationNumberType.value = personalInformation.identificationType ?? .citizenUCN
                self?.gender.value = personalInformation.gender ?? .male
                if let age = personalInformation.age {
                    self?.age.value = "\(age)"
                } else {
                    self?.age.value = nil
                }
                self?.preexistingConditions.value = personalInformation.preExistingConditions
                self?.identificationNumber.value = personalInformation.identificationNumber
                if personalInformation.identificationNumber != nil {
                    self?.validate()
                }
            case .failure(let error):
                self?.requestError.value = error
            }
        }
    }

    func sendPersonalInformation() {
        // show activity indicator
        isLoading.value = true
        var ageOrNil: Int?
        if let value = age.value, !value.isEmpty {
            if let age = Int(value), age > 0 {
                ageOrNil = age
            }
        }
        // send request
        personalInformationRepository.sendPersonalInfo(identificationNumber: identificationNumber.value,
                                                       identificationType: identificationNumberType.value?.identificationType,
                                                       age: ageOrNil,
                                                       gender: gender.value?.genderType,
                                                       preexistingConditions: preexistingConditions.value ?? "") { [weak self] result in
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

    func identificationNumberTextFieldWillUpdateText(_ newString: String) -> Bool {
        guard !newString.isEmpty else { return true }
        switch identificationNumberType.value {
        case .citizenUCN:
            return identificationNumberTextFieldWillUpdateText(ucn: newString)
            #if !MACEDONIA
        case .foreignerPIN:
            return identificationNumberTextFieldWillUpdateText(pin: newString)
        #endif // !MACEDONIA
        case .identificationCard:
            return identificationNumberTextFieldWillUpdateText(cardId: newString)
        default:
            // in case
            return true
        }
    }

    private func identificationNumberTextFieldWillUpdateText(ucn newString: String) -> Bool {
        if newString.count > ucnHelper.maximumPersonalNumberLength {
            return false
        }

        if !newString.isEmpty && newString.count < ucnHelper.maximumPersonalNumberLength {
            return true
        }

        // !!! Side effect
        // If lenght is exact try parse it, if valid egn auto populate disabled controls
        if let data = ucnHelper.parse(ucn: newString) {
            setModelsFromParsedUCNData(data)
        }

        return true
    }

    private func identificationNumberTextFieldWillUpdateText(pin newString: String) -> Bool {
        return !newString.isEmpty && newString.count <= PINForeignerHelper.maximumPersonalNumberLength
    }

    private func identificationNumberTextFieldWillUpdateText(cardId newString: String) -> Bool {
        return !newString.isEmpty && newString.count <= IDCardHelper.maximumPersonalNumberLength
    }

    func ageTextFieldWillUpdateText(_ newString: String) -> Bool {
        guard !newString.isEmpty else { return true }

        let newAge: Int = Int(newString) ?? 0
        return newAge > 0 && newAge <= maximumAge
    }

    func preexistingConditionsTextFieldWillUpdateText(_ newString: String) -> Bool {
        guard !newString.isEmpty else { return true }

        return newString.count <= preexistingConditionsTextLength
    }

    func validate() {
        let errors = validateInput()
        validationErrors.value = validateInput()
        let importantErrors = errors.filter { $0 != .emptyAge }
        isInputValid.value = importantErrors.isEmpty
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
        } catch let error {
            // Only catch the errors if they are PersonalInformationValidationError
            if let error = error as? PersonalInformationValidationError {
                errors.append(error)
            }
        }
    }

    private func validateGender() throws {
        guard let gender = gender.value, gender != .notSelected else {
            throw PersonalInformationValidationError.unknownGender
        }
    }

    private func validateAge() throws {
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

    private func validateIdentificationNumber() throws {
        guard let identificationNumber = identificationNumber.value, !identificationNumber.isEmpty else {
            throw PersonalInformationValidationError.emptyIdentificationNumber
        }

        switch identificationNumberType.value {
        case .citizenUCN:
            try validateUCN(identificationNumber)
            #if !MACEDONIA
        case .foreignerPIN:
            try validatePIN(identificationNumber)
        #endif //!MACEDONIA
        case .identificationCard:
            try validateID(identificationNumber)
        default:
            throw PersonalInformationValidationError.unknownIdentificationNumberType
        }
    }

    private func validateUCN(_ identificationNumber: String) throws {
        if !ucnHelper.isValid(ucn: identificationNumber) {
            switch ucnHelper.ucnType {
            case .bulgarian:
                throw PersonalInformationValidationError.invalidМacedonianCitizenUCN
            case .macedonian:
                throw PersonalInformationValidationError.invalidBulgarianCitizenUCN
            }
        }
    }

    private func validatePIN(_ identificationNumber: String) throws {
        if !PINForeignerHelper().isValid(pin: identificationNumber) {
            throw PersonalInformationValidationError.invalidForeignerPIN
        }
    }

    private func validateID(_ identificationNumber: String) throws {
        if !IDCardHelper().isValid(id: identificationNumber) {
            throw PersonalInformationValidationError.invalidIdentificationCard
        }
    }

    // MARK: Helpers

    private func setModelsFromParsedUCNData(_ data: UCNData) {
        if let birthdate = data.birthdate {
            let years = Date.yearsBetween(startDate: birthdate, endDate: Date())
            age.value = "\(years)"
        }

        gender.value = data.sex
    }

}
//swiftlint:enable file_length
