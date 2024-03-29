import CustomDump
import XCTest

@testable import ElasticsearchQueryBuilder

final class QueryValueTests: XCTestCase {

    func test_array() {
        XCTAssertNoDifference(
            QueryValue.array([Float(0.1), 0.2]),
            QueryValue.array([.float(0.1), .float(0.2)])
        )
        XCTAssertNoDifference(
            QueryValue.array([Double(0.1), 0.2]),
            QueryValue.array([.float(0.1), .float(0.2)])
        )
        XCTAssertNoDifference(
            QueryValue.array([1, 2]),
            QueryValue.array([.int(1), .int(2)])
        )
        XCTAssertNoDifference(
            QueryValue.array(["a", "b"]),
            QueryValue.array([.string("a"), .string("b")])
        )
        struct Custom: CustomStringConvertible {
            var description: String
        }
        XCTAssertNoDifference(
            QueryValue.array(describing: [Custom(description: "a"), Custom(description: "b")]),
            QueryValue.array([.string("a"), .string("b")])
        )
    }

    func test_string() {
        struct Custom: CustomStringConvertible {
            var description: String
        }
        XCTAssertNoDifference(
            QueryValue.string(describing: Custom(description: "a")),
            QueryValue.string("a")
        )
    }
}
