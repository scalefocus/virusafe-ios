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
    
    private let repository: RegistrationRepository
    let shouldShowLoadingIndicator = Observable<Bool>()
    let isRequestSuccessful = Observable<Bool>()
    
    init(repository: RegistrationRepository) {
        self.repository = repository
    }
    
    func didTapRegistration(with phoneNumber: String) {
        shouldShowLoadingIndicator.value = true
        // TODO: Remove delay when requests are implemented
        delay(1) { [weak self] in
            self?.repository.authoriseMobileNumber(mobileNumber: phoneNumber) { [weak self] success in
                guard let strongSelf = self else { return }
                strongSelf.isRequestSuccessful.value = success
                strongSelf.shouldShowLoadingIndicator.value = false
            }
        }
    }
    
}
