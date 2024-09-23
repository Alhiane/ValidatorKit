import Testing
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
        let rule = MinRule(value: 18)
        assert(rule.validate(20) == nil)
        assert(rule.validate(15) != nil)
    }
    
    @Test("Min Rule for String Length")
    func testMinRuleForString() {
        let rule = MinRule(value: 3)
        assert(rule.validate("1234") == nil)
        assert(rule.validate("12") != nil)
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
        assert(rule.validate("12345") == nil)
        assert(rule.validate("123456") != nil)
    }
    @Test("Multi Rules") func testMultipleRulesPerField()  {
        let schema = ValidationSchema()
            .field("password")
                .required()
                .custom (message:  "Message here") { value in
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
    @Test("Schema Validation") func testValidationSchema()  {
        let username: String = "johndoe"
        let schema = ValidationSchema()
            .field("username").required()
            .field("email").required().email()
            .field("gender").requiredIf(username == "johndoe")
            .field("amount").numeric()
            .ready()

        let validData: [String: Any] = [
            "username": "johndoe",
            "email": "john@example.com",
            "gender": "male",
            "amount": 100.09
        ]

        let invalidData: [String: Any] = [
            "username": "",
            "email": "not-an-email",
            "amount": "100.09"
        ]

        let validResult = schema.validate(validData)
         assert(validResult.isValid)
         assert(validResult.errors.isEmpty)

        let invalidResult = schema.validate(invalidData)
         assert(!invalidResult.isValid)
         assert(invalidResult.errors.count == 2)
         assert(invalidResult.errors["username"] != nil)
         assert(invalidResult.errors["email"] != nil)
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
            .field("age").required().custom(message:"Age Custom Validation") { value in
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
         assert(invalidResult.errors.count == 2)
    }
}

