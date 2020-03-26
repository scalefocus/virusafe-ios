//
//  RegistrationViewModel.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 20.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import TwoWayBondage


class RegistrationViewModel {
    
    let repository: RegistrationRepository
    let shouldShowLoadingIndicator = Observable<Bool>()
    let isRequestSuccessful = Observable<AuthoriseMobileNumberResult>()
    
    init(repository: RegistrationRepository) {
        self.repository = repository
    }
    
    func didTapRegistration(with phoneNumber: String) {
        shouldShowLoadingIndicator.value = true
        repository.authoriseMobileNumber(mobileNumber: phoneNumber) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.isRequestSuccessful.value = result
            strongSelf.shouldShowLoadingIndicator.value = false
        }
    }
    
}
