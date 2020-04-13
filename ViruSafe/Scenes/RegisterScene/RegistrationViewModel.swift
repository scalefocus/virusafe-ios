//
//  RegistrationViewModel.swift
//  ViruSafe
//
//  Created by Ivan Georgiev on 20.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import TwoWayBondage

final class RegistrationViewModel {

    private (set) var registrationRepository: RegistrationRepository
    private (set) var termsAndConditionsRepository: TermsAndConditionsRepository

    let shouldShowLoadingIndicator = Observable<Bool>()
    let isRequestSuccessful = Observable<AuthoriseMobileNumberResult>()
    
    init(registrationRepository: RegistrationRepository,
         termsAndConditionsRepository: TermsAndConditionsRepository) {
        self.registrationRepository = registrationRepository
        self.termsAndConditionsRepository = termsAndConditionsRepository
    }
    
    func didTapRegistration(with phoneNumber: String) {
        shouldShowLoadingIndicator.value = true
        registrationRepository.authoriseMobileNumber(mobileNumber: phoneNumber) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.isRequestSuccessful.value = result
            strongSelf.shouldShowLoadingIndicator.value = false
        }
    }
    
}
