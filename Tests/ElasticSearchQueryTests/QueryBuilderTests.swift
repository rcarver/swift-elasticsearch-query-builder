import CustomDump
import XCTest

@testable import ElasticSearchQuery

final class QueryBuilderTests: XCTestCase {
    func testBuild1() throws {
        func build() -> some QueryComponent {
            ElasticSearchQuery {
                BoolQuery {
                    MinimumShouldMatch(1)
                }
            }
        }
        let query = build()
        XCTAssertNoDifference(query.makeData(), [
            "query": [
                "bool": [
                    "minimum_should_match": 1
                ]
            ]
        ])
    }
    func testBuild2() throws {
        func build(tags: [String]?) -> some QueryComponent {
            ElasticSearchQuery {
                BoolQuery {
                    MinimumShouldMatch(1)
                    ShouldQuery {
                        DictQuery("match") {
                            [
                                "query": "Hello World",
                                "type": "phrase_prefix",
                                "field": "message"
                            ]
                        }
                    }
                }
            }
        }
        let query = build(tags: nil)
        XCTAssertNoDifference(query.makeData(), [
            "query": [
                "bool": [
                    "minimum_should_match": 1,
                    "should": [
                        "match": [
                            "query": "Hello World",
                            "type": "phrase_prefix",
                            "field": "message"
                        ]
                    ]
                ]
            ]
        ])
    }
    func testBuildConditional() throws {
        func build(tags: [String]?) -> some QueryComponent {
            ElasticSearchQuery {
                BoolQuery {
                    FilterQuery {
                        if let tags {
                            DictQuery("term") {
                                [
                                    "tags" : .array(tags.map(QueryValue.string))
                                ]
                            }
                        }
                    }
                }
            }
        }
        let queryTrue = build(tags: ["a", "b"])
        XCTAssertNoDifference(queryTrue.makeData(), [
            "query": [
                "bool": [
                    "filter": [
                        "term": [
                            "tags": ["a", "b"]
                        ]
                    ]
                ]
            ]
        ])
        let queryFalse = build(tags: nil)
        XCTAssertNoDifference(queryFalse.makeData(), [
            "query": [
                "bool": [
                    "filter": [:]
                ]
            ]
        ])
    }
}
