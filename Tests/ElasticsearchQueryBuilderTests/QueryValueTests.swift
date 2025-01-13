import CustomDump
import XCTest

@testable import ElasticsearchQueryBuilder

final class QueryValueTests: XCTestCase {

    func test_array() {
        expectNoDifference(
            QueryValue.array([Float(0.1), 0.2]),
            QueryValue.array([.float(0.1), .float(0.2)])
        )
        expectNoDifference(
            QueryValue.array([Double(0.1), 0.2]),
            QueryValue.array([.float(0.1), .float(0.2)])
        )
        expectNoDifference(
            QueryValue.array([1, 2]),
            QueryValue.array([.int(1), .int(2)])
        )
        expectNoDifference(
            QueryValue.array(["a", "b"]),
            QueryValue.array([.string("a"), .string("b")])
        )
        struct Custom: CustomStringConvertible {
            var description: String
        }
        expectNoDifference(
            QueryValue.array(describing: [Custom(description: "a"), Custom(description: "b")]),
            QueryValue.array([.string("a"), .string("b")])
        )
    }

    func test_string() {
        struct Custom: CustomStringConvertible {
            var description: String
        }
        expectNoDifference(
            QueryValue.string(describing: Custom(description: "a")),
            QueryValue.string("a")
        )
    }
}
