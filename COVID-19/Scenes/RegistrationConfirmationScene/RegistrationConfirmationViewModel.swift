//
//  RegistrationConfirmationViewModel.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 20.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import TwoWayBondage

class RegistrationConfirmationViewModel {
    
    let repository: RegistrationRepository
    let shouldShowLoadingIndicator = Observable<Bool>()
    let isCodeAuthorizationRequestSuccessful = Observable<AuthoriseMobileNumberResult>()
    let isResendCodeRequestSuccessful = Observable<AuthoriseMobileNumberResult>()
    let isPersonalNumberRequestSuccessful = Observable<AuthoriseMobileNumberResult>()
    
    init(repository: RegistrationRepository) {
        self.repository = repository
    }
    
    func didTapCodeAuthorization(with authorisationCode: String) {
        shouldShowLoadingIndicator.value = true
        repository.authoriseVerificationCode(verificationCode: authorisationCode) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.isCodeAuthorizationRequestSuccessful.value = result
            strongSelf.shouldShowLoadingIndicator.value = false
        }
    }

    func didTapResetCodeButton() {
        guard let phoneNumber = repository.authorisedMobileNumber else {
            // we should not be here
            return
        }
        shouldShowLoadingIndicator.value = true
        repository.authoriseMobileNumber(mobileNumber: phoneNumber) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.isResendCodeRequestSuccessful.value = result
            strongSelf.shouldShowLoadingIndicator.value = false
        }
    }
    
    func didTapPersonalNumberAuthorization(with personalNumber: String) {
        
        shouldShowLoadingIndicator.value = true
        repository.authorisePersonalNumber(personalNumberNumber: personalNumber, completion: { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.isPersonalNumberRequestSuccessful.value = result
            strongSelf.shouldShowLoadingIndicator.value = false
        })
    }

    func mobileNumber() -> String {
        // TODO: Format phone if needed
        return repository.authorisedMobileNumber ?? "(+359) XXX-XXX"
    }
    
}
