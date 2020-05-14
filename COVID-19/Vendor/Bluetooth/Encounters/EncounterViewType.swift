//
//  EncounterViewType.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 8.04.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

protocol EncounterViewType: class {
    func didAddEncounter(_ encounter: Encounter)
}
