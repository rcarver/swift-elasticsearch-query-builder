import CustomDump
import XCTest

@testable import ElasticSearchQueryBuilder

final class DictQueryBuilderTests: XCTestCase {
    func testBuild1() throws {
        @ElasticSearchQueryBuilder func build(tags: [String]?) -> some ElasticSearchQuery {
            PaginationQuery(first: 10)
        }
        let query = build(tags: nil)
        XCTAssertNoDifference(query.makeQuery(), [
            "query": [
                "first": 10
            ]
        ])
    }
    func testBuild2() throws {
        @ElasticSearchQueryBuilder func build(tags: [String]?) -> some ElasticSearchQuery {
            PaginationQuery(first: 10)
            PaginationQuery(size: 20)
        }
        let query = build(tags: nil)
        XCTAssertNoDifference(query.makeQuery(), [
            "query": [
                "first": 10,
                "size": 20
            ]
        ])
    }
    func testBuildIf() throws {
        @ElasticSearchQueryBuilder func build(bool: Bool) -> some ElasticSearchQuery {
            if bool {
                PaginationQuery(first: 10)
            }
        }
        let queryTrue = build(bool: true)
        XCTAssertNoDifference(queryTrue.makeQuery(), [
            "query": [
                "first": 10,
            ]
        ])
        let queryFalse = build(bool: false)
        XCTAssertNoDifference(queryFalse.makeQuery(), [
            "query": [:]
        ])
    }
}

final class ArrayQueryBuilderTests: XCTestCase {
    func testBuild1() throws {
        @ElasticSearchQueryBuilder func build() -> some ElasticSearchQuery {
            BoolQuery {
                ShouldQuery {
                    DictQuery("match") {
                        [
                            "title": "Hello World"
                        ]
                    }
                }
            }
        }
        let query = build()
        XCTAssertNoDifference(query.makeQuery(), [
            "query": [
                "bool": [
                    "should": [
                        [ "match": [ "title": "Hello World" ] ]
                    ]
                ]
            ]
        ])
    }
    func testBuild2() throws {
        @ElasticSearchQueryBuilder func build() -> some ElasticSearchQuery {
            BoolQuery {
                ShouldQuery {
                    DictQuery("match") {
                        [
                            "title": "Hello World"
                        ]
                    }
                    DictQuery("match") {
                        [
                            "content": "Elasticsearch"
                        ]
                    }
                }
            }
        }
        let query = build()
        XCTAssertNoDifference(query.makeQuery(), [
            "query": [
                "bool": [
                    "should": [
                        [ "match": [ "title": "Hello World" ] ],
                        [ "match": [ "content": "Elasticsearch" ] ],
                    ]
                ]
            ]
        ])
    }
    func testBuildIf() throws {
        @ElasticSearchQueryBuilder func build(title: String?) -> some ElasticSearchQuery {
            BoolQuery {
                ShouldQuery {
                    if let title {
                        DictQuery("match") {
                            [
                                "title": .string(title)
                            ]
                        }
                    }
                    DictQuery("match") {
                        [
                            "content": "Elasticsearch"
                        ]
                    }
                }
            }
        }
        let queryFalse = build(title: nil)
        XCTAssertNoDifference(queryFalse.makeQuery(), [
            "query": [
                "bool": [
                    "should": [
                        [ "match": [ "content": "Elasticsearch" ] ],
                    ]
                ]
            ]
        ])
        let queryTrue = build(title: "Hello World")
        XCTAssertNoDifference(queryTrue.makeQuery(), [
            "query": [
                "bool": [
                    "should": [
                        [ "match": [ "title": "Hello World" ] ],
                        [ "match": [ "content": "Elasticsearch" ] ],
                    ]
                ]
            ]
        ])
    }
    func testBuildArray() throws {
        @ElasticSearchQueryBuilder func build() -> some ElasticSearchQuery {
            BoolQuery {
                ShouldQuery {
                    for str in ["Hello", "World"] {
                        DictQuery("match") {
                            [
                                "title": .string(str)
                            ]
                        }
                    }
                }
            }
        }
        let query = build()
        XCTAssertNoDifference(query.makeQuery(), [
            "query": [
                "bool": [
                    "should": [
                        [ "match": [ "title": "Hello" ] ],
                        [ "match": [ "title": "World" ] ],
                    ]
                ]
            ]
        ])
    }
}
