//
//  LanguagesViewModel.swift
//  COVID-19
//
//  Created by Gandi Pirkov on 30.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation


final class LanguagesViewModel {
    //TODO: Fix format of data when we connect to Flex
    var laguanges:[(String,String)] = [("bg","Български"), ("en_GB","English")]
    private let firstLaunchCheckRepository: AppLaunchRepository
    
    var isInitialFlow: Bool {
        return !firstLaunchCheckRepository.isAppLaunchedBefore
    }
    
    init(firstLaunchCheckRepository: AppLaunchRepository) {
        self.firstLaunchCheckRepository = firstLaunchCheckRepository
    }
}
