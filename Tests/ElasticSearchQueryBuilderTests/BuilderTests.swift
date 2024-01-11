import CustomDump
import XCTest

@testable import ElasticSearchQueryBuilder

final class ElasticSearchQueryBuilderests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build(tags: [String]?) -> some ElasticSearchQuery {
            Query {
                DictQuery("match") {
                    [
                        "title": "Hello World"
                    ]
                }
            }
            PaginationQuery(from: 10)
        }
        let query = build(tags: nil)
        XCTAssertNoDifference(query.makeQuery(), [
            "query": [
                "match": [
                    "title": "Hello World"
                ]
            ],
            "from": 10
        ])
    }
}

final class DictQueryBuilderTests: XCTestCase {
    func testBuild1() throws {
        @ElasticSearchQueryBuilder func build(tags: [String]?) -> some ElasticSearchQuery {
            PaginationQuery(from: 10)
        }
        let query = build(tags: nil)
        XCTAssertNoDifference(query.makeQuery(), [
            "from": 10
        ])
    }
    func testBuild2() throws {
        @ElasticSearchQueryBuilder func build(tags: [String]?) -> some ElasticSearchQuery {
            PaginationQuery(from: 10)
            PaginationQuery(size: 20)
        }
        let query = build(tags: nil)
        XCTAssertNoDifference(query.makeQuery(), [
            "from": 10,
            "size": 20
        ])
    }
    func testBuildIf() throws {
        @ElasticSearchQueryBuilder func build(bool: Bool) -> some ElasticSearchQuery {
            if bool {
                PaginationQuery(from: 10)
            }
        }
        let queryTrue = build(bool: true)
        XCTAssertNoDifference(queryTrue.makeQuery(), [
            "from": 10,
        ])
        let queryFalse = build(bool: false)
        XCTAssertNoDifference(queryFalse.makeQuery(), [:])
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
            "bool": [
                "should": [
                    [ "match": [ "title": "Hello World" ] ]
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
            "bool": [
                "should": [
                    [ "match": [ "title": "Hello World" ] ],
                    [ "match": [ "content": "Elasticsearch" ] ],
                ]
            ]
        ])
    }
    func testBuildIf1() throws {
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
            "bool": [
                "should": [
                    [ "match": [ "content": "Elasticsearch" ] ],
                ]
            ]
        ])
        let queryTrue = build(title: "Hello World")
        XCTAssertNoDifference(queryTrue.makeQuery(), [
            "bool": [
                "should": [
                    [ "match": [ "title": "Hello World" ] ],
                    [ "match": [ "content": "Elasticsearch" ] ],
                ]
            ]
        ])
    }
    func testBuildIf2() throws {
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
                    if let title {
                        DictQuery("match") {
                            [
                                "content": .string(title)
                            ]
                        }
                    }
                }
            }
        }
        let queryFalse = build(title: nil)
        XCTAssertNoDifference(queryFalse.makeQuery(), [
            "bool": [
                "should": []
            ]
        ])
        let queryTrue = build(title: "Hello World")
        XCTAssertNoDifference(queryTrue.makeQuery(), [
            "bool": [
                "should": [
                    [ "match": [ "title": "Hello World" ] ],
                    [ "match": [ "content": "Hello World" ] ],
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
            "bool": [
                "should": [
                    [ "match": [ "title": "Hello" ] ],
                    [ "match": [ "title": "World" ] ],
                ]
            ]
        ])
    }
}
