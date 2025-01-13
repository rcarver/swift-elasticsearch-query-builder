import CustomDump
import XCTest

@testable import ElasticsearchQueryBuilder

final class ElasticsearchQueryBuilderTests: XCTestCase {
    func testBuild() throws {
        @ElasticsearchQueryBuilder func build(tags: [String]?) -> some esb.QueryDSL {
            esb.Query {
                esb.Key("match") {
                    [
                        "title": "Hello World"
                    ]
                }
            }
            esb.Pagination(from: 10)
        }
        let query = build(tags: nil)
        expectNoDifference(query.makeQuery(), [
            "query": [
                "match": [
                    "title": "Hello World"
                ]
            ],
            "from": 10
        ])
    }
    func testBuildIf() throws {
        @ElasticsearchQueryBuilder func build(bool: Bool) -> some esb.QueryDSL {
            if bool {
                esb.Pagination(from: 10)
            }
        }
        let queryTrue = build(bool: true)
        expectNoDifference(queryTrue.makeQuery(), [
            "from": 10
        ])
        let queryFalse = build(bool: false)
        expectNoDifference(queryFalse.makeQuery(), [:])
    }
}

final class DictQueryBuilderTests: XCTestCase {
    func testBuild1() throws {
        @ElasticsearchQueryBuilder func build(tags: [String]?) -> some esb.QueryDSL {
            esb.Pagination(from: 10)
        }
        let query = build(tags: nil)
        expectNoDifference(query.makeQuery(), [
            "from": 10
        ])
    }
    func testBuild2() throws {
        @ElasticsearchQueryBuilder func build(tags: [String]?) -> some esb.QueryDSL {
            esb.Pagination(from: 10)
            esb.Pagination(size: 20)
        }
        let query = build(tags: nil)
        expectNoDifference(query.makeQuery(), [
            "from": 10,
            "size": 20
        ])
    }
    func testBuildIf() throws {
        @ElasticsearchQueryBuilder func build(bool: Bool) -> some esb.QueryDSL {
            esb.Query {
                if bool {
                    esb.Pagination(from: 10)
                }
            }
        }
        let queryTrue = build(bool: true)
        expectNoDifference(queryTrue.makeQuery(), [
            "query": [
                "from": 10
            ]
        ])
        let queryFalse = build(bool: false)
        expectNoDifference(queryFalse.makeQuery(), [:])
    }
    func testBuildEither() throws {
        @ElasticsearchQueryBuilder func build(bool: Bool) -> some esb.QueryDSL {
            esb.Query {
                if bool {
                    esb.Pagination(from: 10)
                } else {
                    esb.Key("from", .int(20))
                }
            }
        }
        let queryTrue = build(bool: true)
        expectNoDifference(queryTrue.makeQuery(), [
            "query": [
                "from": 10
            ]
        ])
        let queryFalse = build(bool: false)
        expectNoDifference(queryFalse.makeQuery(), [
            "query": [
                "from": 20,
            ]
        ])
    }
}

final class ArrayQueryBuilderTests: XCTestCase {
    func testBuild1() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Should {
                esb.Key("match") {
                    [
                        "title": "Hello World"
                    ]
                }
            }
        }
        let query = build()
        expectNoDifference(query.makeQuery(), [
            "should": [
                [ "match": [ "title": "Hello World" ] ]
            ]
        ])
    }
    func testBuild2Homogeneous() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Should {
                esb.Key("match") {
                    [
                        "title": "Hello World"
                    ]
                }
                esb.Key("match") {
                    [
                        "content": "Elasticsearch"
                    ]
                }
            }
        }
        let query = build()
        expectNoDifference(query.makeQuery(), [
            "should": [
                [ "match": [ "title": "Hello World" ] ],
                [ "match": [ "content": "Elasticsearch" ] ],
            ]
        ])
    }
    func testBuild2Heterogeneous() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Should {
                esb.Key("match") {
                    [
                        "title": "Hello World"
                    ]
                }
                esb.Pagination(from: 10)
            }
        }
        let query = build()
        expectNoDifference(query.makeQuery(), [
            "should": [
                [ "match": [ "title": "Hello World" ] ],
                [ "from": 10 ]
            ]
        ])
    }
    func testBuildIf1() throws {
        @ElasticsearchQueryBuilder func build(title: String?) -> some esb.QueryDSL {
            esb.Should {
                if let title {
                    esb.Key("match") {
                        [
                            "title": .string(title)
                        ]
                    }
                }
                esb.Key("match") {
                    [
                        "content": "Elasticsearch"
                    ]
                }
            }
        }
        let queryFalse = build(title: nil)
        expectNoDifference(queryFalse.makeQuery(), [
            "should": [
                [ "match": [ "content": "Elasticsearch" ] ],
            ]
        ])
        let queryTrue = build(title: "Hello World")
        expectNoDifference(queryTrue.makeQuery(), [
            "should": [
                [ "match": [ "title": "Hello World" ] ],
                [ "match": [ "content": "Elasticsearch" ] ],
            ]
        ])
    }
    func testBuildIf2() throws {
        @ElasticsearchQueryBuilder func build(title: String?) -> some esb.QueryDSL {
            esb.Should {
                if let title {
                    esb.Key("match") {
                        [
                            "title": .string(title)
                        ]
                    }
                }
                if let title {
                    esb.Key("match") {
                        [
                            "content": .string(title)
                        ]
                    }
                }
            }
        }
        let queryFalse = build(title: nil)
        expectNoDifference(queryFalse.makeQuery(), [:])
        let queryTrue = build(title: "Hello World")
        expectNoDifference(queryTrue.makeQuery(), [
            "should": [
                [ "match": [ "title": "Hello World" ] ],
                [ "match": [ "content": "Hello World" ] ],
            ]
        ])
    }
    func testBuildEither() throws {
        @ElasticsearchQueryBuilder func build(_ enabled: Bool) -> some esb.QueryDSL {
            esb.Should {
                if enabled {
                    esb.Pagination(from: 10)
                } else {
                    esb.Pagination(from: 20)
                }
            }
        }
        let queryTrue = build(true)
        expectNoDifference(queryTrue.makeQuery(), [
            "should": [
                [ "from": 10 ]
            ]
        ])
        let queryFalse = build(false)
        expectNoDifference(queryFalse.makeQuery(), [
            "should": [
                [ "from": 20 ]
            ]
        ])
    }
    func testBuildArray() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Should {
                for str in ["Hello", "World"] {
                    esb.Key("match") {
                        [
                            "title": .string(str)
                        ]
                    }
                }
            }
        }
        let query = build()
        expectNoDifference(query.makeQuery(), [
            "should": [
                [ "match": [ "title": "Hello" ] ],
                [ "match": [ "title": "World" ] ],
            ]
        ])
    }
}
