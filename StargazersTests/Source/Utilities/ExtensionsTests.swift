import XCTest
@testable import Stargazers

final class ExtensionsTests: XCTestCase {
    func testBoolExtension_NotMethod_FromTrueToFalse() {
        
        /// GIVEN: a true boolean value
        let originalValue: Bool = true
        /// --------------------------------
        
        /// WHEN: .not method on the true boolean is called
        let sut = originalValue.not
        /// --------------------------------
        
        /// THEN: the output is false
        XCTAssertFalse(sut)
        /// --------------------------------
    }
    
    func testBoolExtension_NotMethod_FromFalseToTrue() {
        
        /// GIVEN: a false boolean value
        let originalValue: Bool = false
        /// --------------------------------
        
        /// WHEN: .not method on the true boolean is called
        let sut = originalValue.not
        /// --------------------------------
        
        /// THEN: the output is true
        XCTAssertTrue(sut)
        /// --------------------------------
    }
}
