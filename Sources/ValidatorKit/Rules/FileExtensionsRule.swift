//
//  FileExtensionsRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//

public struct FileExtensionsRule: ValidationRule {
    private let allowedExtensions: [String]
    public let message: String
    
    public init(allowedExtensions: [String], message: String? = nil) {
        self.allowedExtensions = allowedExtensions
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.mimeTypesKey, defaultMessage: ValidationMessage.mimeTypes)
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        guard let filename = value as? String, let fileExtension = filename.split(separator: ".").last?.lowercased() else {
            return ValidationError(message: ValidationMessage.message(for: ValidationMessage.invalidFileKey, defaultMessage: ValidationMessage.invalidFile))
        }
        
        if !allowedExtensions.contains(fileExtension) {
            return ValidationError(message: message)
        }
        return nil
    }
}
