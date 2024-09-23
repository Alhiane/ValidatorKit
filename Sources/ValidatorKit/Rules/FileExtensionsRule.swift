//
//  FileExtensionsRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//

public struct FileExtensionsRule: ValidationRule {
    private let allowedExtensions: [String]
    
    public init(allowedExtensions: [String]) {
        self.allowedExtensions = allowedExtensions
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        guard let filename = value as? String, let fileExtension = filename.split(separator: ".").last?.lowercased() else {
            return ValidationError(message: "Invalid file")
        }
        
        if !allowedExtensions.contains(fileExtension) {
            return ValidationError(message: "File extension not allowed")
        }
        return nil
    }
}
