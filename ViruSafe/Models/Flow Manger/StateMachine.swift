//
//  StateMachine.swift
//  ViruSafe
//
//  Created by Aleksandar Sergeev Petrov on 28.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

// Finite-state machine
protocol StateMachineDelegateProtocol: class {

    associatedtype StateType

    func shouldTransition(from oldState: StateType, to newState: StateType) -> Bool
    func didTransition(from oldState: StateType, to newState: StateType)

}

// Base State Machine

class StateMachine <T: StateMachineDelegateProtocol> {

    // MARK: - Public

    var state: T.StateType {
        get {
            return _state
        }
        set {
            if delegate.shouldTransition(from: _state, to: newValue) {
                _state = newValue
            }
        }
    }

    // MARK: - Lifecycle

    init(initialState state: T.StateType, delegate: T) {
        _state = state
        self.delegate = delegate
    }

    // MARK: - Private

    // we need it
    private unowned var delegate: T

    private var _state: T.StateType {
        didSet {
            // Perform Entry and Exit Actions
            delegate.didTransition(from: oldValue, to: _state)
        }
    }

}
