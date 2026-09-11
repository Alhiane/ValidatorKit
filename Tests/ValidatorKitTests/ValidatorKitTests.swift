import Testing
import Foundation
@testable import ValidatorKit

// suits
@Suite("Rules Test")
struct RulesTests {
    @Test("Required Rule") func testRequiredRule() {
        let rule = RequiredRule()
         assert(rule.validate("Not empty") == nil)
         assert(rule.validate("") != nil)
         assert(rule.validate(nil) != nil)
    }
    @Test("Email Rule") func testEmailRule() {
        let rule = EmailRule()
         assert(rule.validate("test@example.com") == nil)
         assert(rule.validate("not an email") != nil)
         assert(rule.validate("") != nil)
         assert(rule.validate(nil) != nil)
    }
    @Test("Min Rule for Int")
    func testMinRuleForInt() {
        let rule = MinRule(value: 18.01)
        assert(rule.validate(20) == nil)
        assert(rule.validate(15) != nil)
        assert(rule.validate(18.00) != nil)
    }

    @Test("Min Rule for String Length")
    func testMinRuleForString() {
        let rule = MinRule(value: 3)
        assert(rule.validate("123") == nil)
        assert(rule.validate("12") == nil)
        assert(rule.validate("abc") == nil)
        assert(rule.validate("ab") != nil)
    }

    @Test("Max Rule for Int")
    func testMaxRuleForInt() {
        let rule = MaxRule(value: 100)
        assert(rule.validate(99) == nil)
        assert(rule.validate(101) != nil)
    }

    @Test("Max Rule for String Length")
    func testMaxRuleForString() {
        let rule = MaxRule(value: 5)
        assert(rule.validate("5") == nil)
        assert(rule.validate("123456") != nil)
        assert(rule.validate("abcde") == nil)
        assert(rule.validate("abcdef") != nil)
    }

    @Test("Min Rule for String Length with Emoji")
    func testMinRuleForStringWithEmoji() {
        let rule = MinRule(value: 1)
        // Flag emoji (regional indicator symbols) - counts as 1 grapheme cluster
        assert(rule.validate("🇺🇸") == nil)
        // Single emoji - counts as 1 grapheme cluster
        assert(rule.validate("😀") == nil)
        assert(rule.validate("") != nil)
    }

    @Test("Max Rule for String Length with Emoji")
    func testMaxRuleForStringWithEmoji() {
        let rule = MaxRule(value: 3)
        // Flag emoji - counts as 1 grapheme cluster
        assert(rule.validate("🇺🇸") == nil)
        // ZWJ sequence (family emoji) - counts as 1 grapheme cluster
        assert(rule.validate("👨‍👩‍👧‍👦") == nil)
        // Multiple emojis - counts as 3 grapheme clusters
        assert(rule.validate("😀😁😂") == nil)
        // Too many - counts as 4 grapheme clusters
        assert(rule.validate("😀😁😂🤣") != nil)
    }

    @Test("Min/Max Rule with Combining Diacritics")
    func testMinMaxRuleWithCombiningDiacritics() {
        let minRule = MinRule(value: 1)
        let maxRule = MaxRule(value: 5)

        // Base character + combining diacritic - counts as 1 grapheme cluster
        let combined = "e\u{0301}" // é as e + combining acute accent
        assert(minRule.validate(combined) == nil)
        assert(maxRule.validate(combined) == nil)

        // Arabic text with combining marks
        let arabic = "مَرْحَبًا" // "hello" in Arabic with diacritics
        assert(maxRule.validate(arabic) == nil)
        assert(minRule.validate(arabic) == nil)
    }
    @Test("Multi Rules") func testMultipleRulesPerField() {
        let schema = ValidationSchema()
            .field("password")
                .required()
                .custom(message: "Message here") { value in
                    guard let password = value as? String, password.count >= 8 else {
                        return false
                    }
                    return true
                }
                .ready()

        let validData: [String: Any] = ["password": "password123"]
        let invalidData: [String: Any] = ["password": "short"]

        let validResult = schema.validate(validData)
         assert(validResult.isValid)

        let invalidResult = schema.validate(invalidData)
         assert(!invalidResult.isValid)
         assert(invalidResult.errors["password"]?.count == 1)
    }
}

// schema
@Suite("Schema Test")
struct SchemaTests {
    @Test("Schema Validation") func testValidationSchema() {
        let username: String = "johndoe"
        let schema = ValidationSchema()
            .field("username").required()
            .field("email").required().email()
            .field("gender").requiredIf(username == "johndoe")
            .field("amount").numeric().min(100.08)
            .ready()

        let validData: [String: Any] = [
            "username": "jhsa",
            "email": "john@example.com",
            "gender": "male",
            "amount": "100.09"
        ]

        let invalidData: [String: Any] = [
            "username": "",
            "email": "not-an-email",
            "amount": 100.09
        ]

        let validResult = schema.validate(validData)
         assert(validResult.isValid)
         assert(validResult.errors.isEmpty)

        let invalidResult = schema.validate(invalidData)
         assert(!invalidResult.isValid)

         assert(invalidResult.errors.count == 3)
         assert(invalidResult.errors["username"] != nil)
         assert(invalidResult.errors["email"] != nil)
         assert(invalidResult.errors["gender"] != nil)
    }
}

// chanied fileds validation
@Suite("Chained Fields Validation")
struct ChainedFieldsTests {
    @Test func testChainedFieldValidation() {
        let schema = ValidationSchema()
            .field("username").required()
            .field("email").required().email()
            .field("habbites").required()
            .field("age").required().custom(message: "Age Custom Validation") { value in
                guard let age = value as? Int, age >= 18 else {
                    return false
                }
                return true
            }
            .ready()

        let validData: [String: Any] = [
            "username": "johndoe",
            "email": "john@example.com",
            "habbites": ["coding", "swift", "travel"],
            "age": 25
        ]

        let validResult = schema.validate(validData)
         assert(validResult.isValid)

        let invalidData: [String: Any] = [
            "username": "janedoe",
            "email": "not-an-email",
            "age": 16
        ]

        let invalidResult = schema.validate(invalidData)
         assert(!invalidResult.isValid)
         assert(invalidResult.errors.count == 3)
         assert(invalidResult.errors["habbites"] != nil)
    }
}

@Suite("Missing Key Validation")
struct MissingKeyValidationTests {
    @Test("Required field with entirely missing key fails validation")
    func testRequiredFieldMissingKeyFails() {
        let schema = ValidationSchema()
            .field("name").required()
            .ready()

        // Note: the key "name" is entirely absent here, not just an empty string.
        let result = schema.validate([:])

        assert(!result.isValid)
        assert(result.errors["name"] != nil)
    }
}

@Suite("Validations Messages")
struct ValidationsMessagesTests {
    @Test("Email Rule with Custom Message") func testEmailRuleWithCustomMessage() {
        let customMessage = "Please enter a valid email address."
        let schema = ValidationSchema()
            .field("email").email(message: customMessage)
            .ready()

        let invalidData = ["email": "not-an-email"]
        let result = schema.validate(invalidData)

        assert(!result.isValid)
        print(result.errors)
        assert(result.errors["email"]?.first == customMessage)
    }

    // test range
    @Test("Range Rule with Custom Message") func testRangeRuleWithCustomMessage() {

        let schema = ValidationSchema()
            .field("number").range(1...10)
            .ready()

        let invalidData = ["number": 21]
        let result = schema.validate(invalidData)
        assert(result.errors["number"]?.isEmpty == false)
    }
}

@Suite("Date Rule Tests")
struct DateRuleTests {
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    @Test("Valid Date")
    func testValidDate() {
        let rule = DateRule()
        let date = Date()
        assert(rule.validate(date) == nil)
    }

    @Test("Invalid Date Type")
    func testInvalidDateType() {
        let rule = DateRule()
        assert(rule.validate("Not a date") != nil)
        assert(rule.validate(123) != nil)
    }

    @Test("Valid String Date")
    func testValidStringDate() {
        let rule = DateRule(format: "yyyy-MM-dd")
        assert(rule.validate("2023-09-28") == nil)
    }

    @Test("Invalid String Date Format")
    func testInvalidStringDateFormat() {
        let rule = DateRule(format: "yyyy-MM-dd")
        assert(rule.validate("28/09/2023") != nil)
    }

    @Test("Date Within Range")
    func testDateWithinRange() {
        let fromDate = dateFormatter.date(from: "2023-01-01")!
        let toDate = dateFormatter.date(from: "2023-12-31")!
        let rule = DateRule(range: DateRange(from: fromDate, to: toDate))

        assert(rule.validate("2023-06-15") == nil)
        assert(rule.validate(dateFormatter.date(from: "2023-06-15")!) == nil)
    }

    @Test("Date Before Range")
    func testDateBeforeRange() {
        let fromDate = dateFormatter.date(from: "2023-01-01")!
        let rule = DateRule(range: DateRange(from: fromDate))

        assert(rule.validate("2022-12-31") != nil)
        assert(rule.validate(dateFormatter.date(from: "2022-12-31")!) != nil)
    }

    @Test("Date After Range")
    func testDateAfterRange() {
        let toDate = dateFormatter.date(from: "2023-12-31")!
        let rule = DateRule(range: DateRange(to: toDate))

        assert(rule.validate("2024-01-01") != nil)
        assert(rule.validate(dateFormatter.date(from: "2024-01-01")!) != nil)
    }

}
