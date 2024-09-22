//
//  Publisher+Validation.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//
import Foundation
import Combine

extension Publisher where Output == String {
    public func validate(key: String) -> AnyPublisher<[ValidationError], Failure> {
        self.map { value in
            ValidatorKit.shared.validate(value, forKey: key)
        }
        .eraseToAnyPublisher()
    }
}
