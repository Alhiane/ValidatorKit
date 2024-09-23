//
//  ValidationError.swift
//  ValidatorKit
//
//  Created by Alhiane on 22/9/2024.
//
import Foundation

public struct ValidationError: Error, Equatable {
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
}
