import XCTest
@testable import Stargazers

final class ExtensionsTests: XCTestCase {
    func testBoolExtension_NotProperty_FromTrueToFalse() {
        
        /// GIVEN: a true boolean value
        let originalValue: Bool = true
        /// --------------------------------
        
        /// WHEN: .not property on the true boolean is called
        let sut = originalValue.not
        /// --------------------------------
        
        /// THEN: the output is false
        XCTAssertFalse(sut)
        /// --------------------------------
    }
    
    func testBoolExtension_NotProperty_FromFalseToTrue() {
        
        /// GIVEN: a false boolean value
        let originalValue: Bool = false
        /// --------------------------------
        
        /// WHEN: .not property on the true boolean is called
        let sut = originalValue.not
        /// --------------------------------
        
        /// THEN: the output is true
        XCTAssertTrue(sut)
        /// --------------------------------
    }
    
    func testOptional_GetMethod_GetWrappedValueOnSome() {
        
        /// GIVEN: an optional variable with some wrapped value inside
        let expectedValue = "TEST"
        let orValue = "not used"
        let originalValue: String? = expectedValue
        /// --------------------------------
        
        /// WHEN: .get method is called with any or value
        let sut = originalValue.get(or: orValue)
        /// --------------------------------
        
        /// THEN: the output is the original value
        XCTAssertEqual(sut, expectedValue)
        /// --------------------------------
    }
    
    func testOptional_GetMethod_GetOrValueOnNone() {
        
        /// GIVEN: an optional variable with none value inside
        let expectedValue = "TEST"
        let originalValue: String? = nil
        /// --------------------------------
        
        /// WHEN: .get method is called with a specific value
        let sut = originalValue.get(or: expectedValue)
        /// --------------------------------
        
        /// THEN: the output is the or value
        XCTAssertEqual(sut, expectedValue)
        /// --------------------------------
    }
}
