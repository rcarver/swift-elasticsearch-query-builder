import CustomDump
import XCTest

@testable import ElasticsearchQueryBuilder

final class EncodingTests: XCTestCase {

    func assertFormattedDate(
        _ value: QueryValue,
        _ want: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let encoder = JSONEncoder()
        let got = try encoder.encode(value)
        let gotString = try XCTUnwrap(String(data: got, encoding: .utf8), file: file, line: line)
        XCTAssertNoDifference(gotString, want, file: file, line: line)
    }

    func assertFormattedDate(
        _ value: Date,
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy,
        _ want: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = dateEncodingStrategy
        let got = try encoder.encode(value)
        let gotString = try XCTUnwrap(String(data: got, encoding: .utf8), file: file, line: line)
        XCTAssertNoDifference(gotString, want, file: file, line: line)
    }

    let date = Date(timeIntervalSince1970: 1001.12345)

    func test_date_iso8601() throws {
        try assertFormattedDate(
            .date(date, format: .iso8601),
            """
            "1970-01-01T00:16:41Z"
            """
        )
        try assertFormattedDate(
            date,
            dateEncodingStrategy:.iso8601,
            """
            "1970-01-01T00:16:41Z"
            """
        )
    }
    func test_date_secondsSince1970() throws {
        try assertFormattedDate(
            .date(date, format: .secondsSince1970),
            """
            "1001"
            """
        )
        try assertFormattedDate(
            date,
            dateEncodingStrategy: .secondsSince1970,
            """
            1001.1234500408173
            """
        )
    }
    func test_date_millisecondsSince1970() throws {
        try assertFormattedDate(
            .date(date, format: .millisecondsSince1970),
            """
            "1001123"
            """
        )
        try assertFormattedDate(
            date,
            dateEncodingStrategy:.millisecondsSince1970,
            """
            1001123.4500408173
            """
        )
    }
}
