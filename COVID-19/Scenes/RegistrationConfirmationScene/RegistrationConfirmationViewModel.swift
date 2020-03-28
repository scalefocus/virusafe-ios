//
//  RegistrationConfirmationViewModel.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 20.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import TwoWayBondage

final class RegistrationConfirmationViewModel {
    
    private let registrationRepository: RegistrationRepository
    private let firstLaunchCheckRepository: AppLaunchRepository
    let shouldShowLoadingIndicator = Observable<Bool>()
    let isCodeAuthorizationRequestSuccessful = Observable<AuthoriseMobileNumberResult>()
    let isResendCodeRequestSuccessful = Observable<AuthoriseMobileNumberResult>()

    var isInitialFlow: Bool {
        return !firstLaunchCheckRepository.isAppLaunchedBefore
    }
    
    init(registrationRepository: RegistrationRepository, firstLaunchCheckRepository: AppLaunchRepository) {
        self.registrationRepository = registrationRepository
        self.firstLaunchCheckRepository = firstLaunchCheckRepository
    }
    
    func didTapCodeAuthorization(with authorisationCode: String) {
        shouldShowLoadingIndicator.value = true
        registrationRepository.authoriseVerificationCode(verificationCode: authorisationCode) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.isCodeAuthorizationRequestSuccessful.value = result
            strongSelf.shouldShowLoadingIndicator.value = false
        }
    }

    func didTapResetCodeButton() {
        guard let phoneNumber = registrationRepository.authorisedMobileNumber else {
            // we should not be here
            return
        }
        shouldShowLoadingIndicator.value = true
        registrationRepository.authoriseMobileNumber(mobileNumber: phoneNumber) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.isResendCodeRequestSuccessful.value = result
            strongSelf.shouldShowLoadingIndicator.value = false
        }
    }

    func mobileNumber() -> String {
        // TODO: Format phone if needed
        return registrationRepository.authorisedMobileNumber ?? "(+359) XXX-XXX"
    }
    
}
