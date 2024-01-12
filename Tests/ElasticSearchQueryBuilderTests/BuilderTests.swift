import CustomDump
import XCTest

@testable import ElasticSearchQueryBuilder

final class ElasticSearchQueryBuilderTests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build(tags: [String]?) -> some esb.QueryDSL {
            esb.Query {
                esb.Dict("match") {
                    [
                        "title": "Hello World"
                    ]
                }
            }
            esb.Pagination(from: 10)
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
        @ElasticSearchQueryBuilder func build(tags: [String]?) -> some esb.QueryDSL {
            esb.Pagination(from: 10)
        }
        let query = build(tags: nil)
        XCTAssertNoDifference(query.makeQuery(), [
            "from": 10
        ])
    }
    func testBuild2() throws {
        @ElasticSearchQueryBuilder func build(tags: [String]?) -> some esb.QueryDSL {
            esb.Pagination(from: 10)
            esb.Pagination(size: 20)
        }
        let query = build(tags: nil)
        XCTAssertNoDifference(query.makeQuery(), [
            "from": 10,
            "size": 20
        ])
    }
    func testBuildIf() throws {
        @ElasticSearchQueryBuilder func build(bool: Bool) -> some esb.QueryDSL {
            if bool {
                esb.Pagination(from: 10)
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
        @ElasticSearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Bool {
                esb.Should {
                    esb.Dict("match") {
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
        @ElasticSearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Bool {
                esb.Should {
                    esb.Dict("match") {
                        [
                            "title": "Hello World"
                        ]
                    }
                    esb.Dict("match") {
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
        @ElasticSearchQueryBuilder func build(title: String?) -> some esb.QueryDSL {
            esb.Bool {
                esb.Should {
                    if let title {
                        esb.Dict("match") {
                            [
                                "title": .string(title)
                            ]
                        }
                    }
                    esb.Dict("match") {
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
        @ElasticSearchQueryBuilder func build(title: String?) -> some esb.QueryDSL {
            esb.Bool {
                esb.Should {
                    if let title {
                        esb.Dict("match") {
                            [
                                "title": .string(title)
                            ]
                        }
                    }
                    if let title {
                        esb.Dict("match") {
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
        @ElasticSearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Bool {
                esb.Should {
                    for str in ["Hello", "World"] {
                        esb.Dict("match") {
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
