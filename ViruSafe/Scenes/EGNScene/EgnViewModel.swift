//
//  EgnViewModel.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 28.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import TwoWayBondage

final class PersonalInformationViewModel {
    let repository: RegistrationRepository

    let isPersonalNumberRequestSuccessful = Observable<AuthoriseMobileNumberResult>()
    let shouldShowLoadingIndicator = Observable<Bool>()

    init(repository: RegistrationRepository) {
        self.repository = repositoryr
    }
    
    func didTapPersonalNumberAuthorization(with personalNumber: String) {

        shouldShowLoadingIndicator.value = true
        repository.authorisePersonalNumber(personalNumberNumber: personalNumber, completion: { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.isPersonalNumberRequestSuccessful.value = result
            strongSelf.shouldShowLoadingIndicator.value = false
        })
    }
}
