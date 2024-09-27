//
//  Localizable.strings
//  ValidatorKit
//
//  Created by Alhiane on 26/9/2024.
//

import Foundation

struct ValidationMessage {
    // Default messages
    static let custom = "Validation failed."
    static let email = "Please enter a valid email address."
    static let min = "Value must be at least %@." // Placeholder for value
    static let max = "Value must be no more than %@."
    static let minLength = "Value must be at least %@ characters long."
    static let maxLength = "Value must be no more than %@ characters long."
    static let numeric = "Please enter a numeric value."
    static let date = "Please enter a valid date."
    static let dateFormat = "Please enter a valid date in the format %@."
    static let range = "Value must be between %@ and %@." // Placeholders for min and max
    static let pattern = "Value does not match the required pattern."
    static let url = "Please enter a valid URL."
    static let inArray = "Value must be one of the allowed options."
    static let requiredIf = "This field is required based on the specified condition."
    static let required = "This field is required."
    static let greaterThan = "Value must be greater than %@."
    static let lessThan = "Value must be less than %@."
    static let mimeTypes = "File type must be one of the allowed types: %@."
    static let notNull = "Value must not be null."
    static let invalidType = "Invalid value type"
    static let invalidFile = "Invalid file"
    static let invalidValue = "Invalid value"
    static let dateRangeTooEarly = "Date must not be earlier than %@."
    static let dateRangeTooLate = "Date must not be later than %@."

    // Localization keys
    static let customKey = "validation.custom"
    static let emailKey = "validation.email"
    static let minKey = "validation.min"
    static let maxKey = "validation.max"
    static let minLengthKey = "validation.minLength"
    static let maxLengthKey = "validation.maxLength"
    static let numericKey = "validation.numeric"
    static let dateKey = "validation.date"
    static let rangeKey = "validation.range"
    static let patternKey = "validation.pattern"
    static let urlKey = "validation.url"
    static let inArrayKey = "validation.inArray"
    static let requiredIfKey = "validation.requiredIf"
    static let requiredKey = "validation.required"
    static let greaterThanKey = "validation.greaterThan"
    static let lessThanKey = "validation.lessThan"
    static let mimeTypesKey = "validation.mimeTypes"
    static let notNullKey = "validation.notnull"
    static let invalidTypeKey = "validation.invalidType"
    static let invalidFileKey = "validation.invalidFile"
    static let invalidValueKey = "validation.invalidValue"
    static let dateFormatKey = "validation.date.format"
    static let dateRangeTooEarlyKey = "validation.date.tooEarly"
    static let dateRangeTooLateKey = "validation.date.tooLate"
    
    // Method to retrieve localized message or fallback to default
    public static func message(for key: String, defaultMessage: String, dynamicValues: [CVarArg] = []) -> String {
            let bundle = Bundle.module // Use the current module's bundle
            let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")
            if localizedString != key {
                return String(format: localizedString, arguments: dynamicValues)
            }
            return String(format: defaultMessage, arguments: dynamicValues)
        }
}
