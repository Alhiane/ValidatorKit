//
//  ValidationRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 22/9/2024.
//

import Foundation

public protocol ValidationRule {
    func validate(_ value: Any?) -> ValidationError?
    var message: String { get }
}
