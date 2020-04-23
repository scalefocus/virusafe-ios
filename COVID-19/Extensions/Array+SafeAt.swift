//
//  Array+SafeAt.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

extension Array {
    subscript(safeAt index: Int) -> Element? {
        guard index < count, index >= 0 else { return nil }

        return self[index]
    }
}
