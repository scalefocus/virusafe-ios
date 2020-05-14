//
//  EncountersManagerType.swift
//  iPlayWithBT
//
//  Created by Aleksandar Sergeev Petrov on 6.04.20.
//  Copyright © 2020 Aleksandar Sergeev Petrov. All rights reserved.
//

import Foundation

protocol EncountersManagerType: BeaconIdAgent {
    func addNewEncounter(_ encounter: Encounter) throws
}
