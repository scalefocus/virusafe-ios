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

protocol PersonalInformationViewModelDelegate: class {
    func sendPersonalInformation(_ request: PersonalInformation,
                                 with completion: @escaping SendPersonalInfoCompletion)
    func sendDelayedAnswers(with completion: @escaping SendAnswersCompletion)
}

final class PersonalInformationViewModel {

    private weak var delegate: PersonalInformationViewModelDelegate?

    private let firstLaunchCheckRepository: AppLaunchRepository
    private let personalInformationRepository: PersonalInformationRepository

    let isInitialFlow: Bool

    let isSendPersonalInformationCompleted = Observable<Bool>()

//    let isSendAnswersCompleted = Observable<Bool>()
    let shouldShowLoadingIndicator = Observable<Bool>()

    var age = Observable<String>()
    var gender = Observable<Gender>()
    var preexistingConditions = Observable<String>()
    var identificationNumber = Observable<String>()

    let requestError = Observable<ApiError>()

    init(firstLaunchCheckRepository: AppLaunchRepository,
         personalInformationRepository: PersonalInformationRepository,
         delegate: PersonalInformationViewModelDelegate) {
        self.firstLaunchCheckRepository = firstLaunchCheckRepository
        self.personalInformationRepository = personalInformationRepository
        self.delegate = delegate
        isInitialFlow = !firstLaunchCheckRepository.isAppLaunchedBefore
    }
    
    func start() {
        shouldShowLoadingIndicator.value = true
        personalInformationRepository.requestPersonalInfo { [weak self] result in
            // hide activity indicator
            self?.shouldShowLoadingIndicator.value = false
            // Handle result
            switch result {
                case .success(let personalInformation):
                    guard let personalInformation = personalInformation else {
                        // Can not parse response
                        self?.requestError.value = .general
                        return
                    }
                    self?.gender.value = personalInformation.gender
                    if let age = personalInformation.age {
                        self?.age.value = "\(age)"
                    }
                    self?.preexistingConditions.value = personalInformation.preExistingConditions
                    self?.identificationNumber.value = personalInformation.identificationNumber
                case .failure(let error):
                    self?.requestError.value = error
            }
        }
    }
    
    func didTapPersonalNumberAuthorization(with personalNumber: String) {
        shouldShowLoadingIndicator.value = true
        let ageString = age.value ?? ""
        let ageInt = Int(ageString)

        let request = PersonalInformation(identificationNumber: personalNumber,
                                          phoneNumber: "", // !!! It is not important in the request
                                          age: ageInt ?? 0,
                                          gender: gender.value ?? .notSelected,
                                          preExistingConditions: preexistingConditions.value ?? "")
        delegate?.sendPersonalInformation(request) { [weak self] result in
            // if we're gone do nothing
            guard let strongSelf = self else { return }
            // hide activity indicator
            strongSelf.shouldShowLoadingIndicator.value = false
            // handle result
            switch result {
                case .success:
                    strongSelf.isSendPersonalInformationCompleted.value = true
                    // !!! If first launch of the app, mark registration as completed
                    strongSelf.firstLaunchCheckRepository.isAppLaunchedBefore = true
                case .failure(let reason):
                    strongSelf.requestError.value = reason
            }
        }
    }

//    func didTapSkipButton() {
//        shouldShowLoadingIndicator.value = true
//        delegate?.sendDelayedAnswers { [weak self] result in
//            // if we're gone do nothing
//            guard let strongSelf = self else { return }
//            // hide activity indicator
//            strongSelf.shouldShowLoadingIndicator.value = false
//            switch result {
//                case .success:
//                    strongSelf.isSendAnswersCompleted.value = true
//                case .failure(let reason):
//                    strongSelf.requestError.value = reason
//            }
//        }
//    }
}
