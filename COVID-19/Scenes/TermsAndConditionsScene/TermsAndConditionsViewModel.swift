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

    let isAcceptButtonVisible: Bool

    private let defaultAcceptButtonVisibility = true

    init(isAcceptButtonVisible: Bool) {
        self.isAcceptButtonVisible = isAcceptButtonVisible
    }

}
