//
//  TermsAndConditionsViewModel.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 23.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import TwoWayBondage

final class TermsAndConditionsViewModel {

    private (set) var repository: TermsAndConditionsRepository
    
    init(repository: TermsAndConditionsRepository) {
        self.repository = repository
    }

}
