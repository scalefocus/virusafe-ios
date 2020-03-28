//
//  EgnViewModel.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 28.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import TwoWayBondage

protocol PersonalInformationViewModelDelegate: class {
    func sendPersonalInformation(_ request: PersonalInformationRequest,
                                 with completion: @escaping ((AuthoriseMobileNumberResult) -> Void))
    func sendDelayedAnswers(with completion: @escaping SendAnswersCompletion)
}

final class PersonalInformationViewModel {

    private weak var delegate: PersonalInformationViewModelDelegate?

    let firstLaunchCheckRepository: AppLaunchRepository

    var isInitialFlow: Bool {
        return !firstLaunchCheckRepository.isAppLaunchedBefore
    }

    let isPersonalNumberRequestSuccessful = Observable<AuthoriseMobileNumberResult>()
    let requestError = Observable<ApiError>()
    let isSendAnswersCompleted = Observable<Bool>()
    let shouldShowLoadingIndicator = Observable<Bool>()

    init(firstLaunchCheckRepository: AppLaunchRepository,
         delegate: PersonalInformationViewModelDelegate) {
        self.firstLaunchCheckRepository = firstLaunchCheckRepository
        self.delegate = delegate
    }
    
    func didTapPersonalNumberAuthorization(with personalNumber: String) {
        shouldShowLoadingIndicator.value = true
        let request = PersonalInformationRequest(personalNumber: personalNumber)
        delegate?.sendPersonalInformation(request) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.isPersonalNumberRequestSuccessful.value = result
            strongSelf.shouldShowLoadingIndicator.value = false
        }
    }

    func didTapSkipButton() {
        shouldShowLoadingIndicator.value = true
        delegate?.sendDelayedAnswers { [weak self] result in
            // if we're gone do nothing
            guard let strongSelf = self else { return }
            // hide activity indicator
            strongSelf.shouldShowLoadingIndicator.value = false
            switch result {
                case .success:
                    strongSelf.isSendAnswersCompleted.value = true
                case .failure(let reason):
                    strongSelf.requestError.value = reason
            }
        }
    }
}
