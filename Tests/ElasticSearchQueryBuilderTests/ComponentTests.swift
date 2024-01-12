import CustomDump
import XCTest

@testable import ElasticSearchQueryBuilder

final class NothingTests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Nothing()
        }
        XCTAssertNoDifference(build().makeQuery(), [:])
    }
}

final class KeyTests: XCTestCase {
    func testBuildValue() throws {
        @ElasticSearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Key("boost", .float(1.2))
        }
        XCTAssertNoDifference(build().makeQuery(), [
            "boost": 1.2
        ])
    }
    func testBuildDict() throws {
        @ElasticSearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Key("match_bool_prefix") {
                [
                    "message": "quick brown f"
                ]
            }
        }
        XCTAssertNoDifference(build().makeQuery(), [
            "match_bool_prefix": [
                "message": "quick brown f"
            ]
        ])
    }
    func testBuildDictEmpty() throws {
        @ElasticSearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Key("match", .dict([:]))
        }
        XCTAssertNoDifference(build().makeQuery(), [:])
    }
}

final class QueryTests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Query {
                esb.Key("match_bool_prefix") {
                    [
                        "message": "quick brown f"
                    ]
                }
            }
        }
        XCTAssertNoDifference(build().makeQuery(), [
            "query": [
                "match_bool_prefix": [
                    "message": "quick brown f"
                ]
            ]
        ])
    }
    func testBuildEmpty() throws {
        @ElasticSearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Query {
                esb.Key("match", .dict([:]))
            }
        }
        XCTAssertNoDifference(build().makeQuery(), [:])
    }
}

final class BoolTests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build(_ enabled: Bool) -> some esb.QueryDSL {
            esb.Bool {
                esb.MinimumShouldMatch(1)
                esb.Should {
                    if enabled {
                        esb.Key("match_bool_prefix") {
                            [
                                "message": "quick brown f"
                            ]
                        }
                    }
                }
                esb.Must {
                    if enabled {
                        esb.Key("match_bool_prefix") {
                            [
                                "message": "quick brown f"
                            ]
                        }
                    }
                }
                esb.MustNot {
                    if enabled {
                        esb.Key("match_bool_prefix") {
                            [
                                "message": "quick brown f"
                            ]
                        }
                    }
                }
                esb.Filter {
                    if enabled {
                        esb.Key("match_bool_prefix") {
                            [
                                "message": "quick brown f"
                            ]
                        }
                    }
                }
            }
        }
        XCTAssertNoDifference(build(true).makeQuery(), [
            "bool": [
                "minimum_should_match": 1,
                "should": [
                    [
                        "match_bool_prefix": [
                            "message": "quick brown f"
                        ]
                    ]
                ],
                "must": [
                    [
                        "match_bool_prefix": [
                            "message": "quick brown f"
                        ]
                    ]
                ],
                "must_not": [
                    [
                        "match_bool_prefix": [
                            "message": "quick brown f"
                        ]
                    ]
                ],
                "filter": [
                    [
                        "match_bool_prefix": [
                            "message": "quick brown f"
                        ]
                    ]
                ]
            ]
        ])
        XCTAssertNoDifference(build(false).makeQuery(), [
            "bool": [
                "minimum_should_match": 1
            ]
        ])
    }
    func testBuildEmpty() throws {
        @ElasticSearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Bool {
                esb.Should {
                    esb.Key("match", .dict([:]))
                }
                esb.Must {
                    esb.Key("match", .dict([:]))
                }
                esb.MustNot {
                    esb.Key("match", .dict([:]))
                }
                esb.Filter {
                    esb.Key("match", .dict([:]))
                }
            }
        }
        XCTAssertNoDifference(build().makeQuery(), [:])
    }
}

final class FunctionScoreTests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.FunctionScore {
                esb.Bool {
                    esb.Should {
                        esb.Key("match_bool_prefix") {
                            [
                                "message": "quick brown f"
                            ]
                        }
                    }
                }
                esb.Boost(3.2)
                esb.BoostMode(.sum)
                esb.ScoreMode(.avg)
                esb.FunctionsList {
                    esb.Function {
                        [
                            "filter": [ "match": [ "test": "cat" ] ],
                            "weight": 42
                        ]
                    }
                }
            }
        }
        XCTAssertNoDifference(build().makeQuery(), [
            "function_score": [
                "bool": [
                    "should": [
                        [
                            "match_bool_prefix": [
                                "message": "quick brown f"
                            ]
                        ]
                    ]
                ],
                "boost": 3.2,
                "boost_mode": "sum",
                "score_mode": "avg",
                "functions": [
                    [
                        "filter": [ "match": [ "test": "cat" ] ],
                        "weight": 42
                    ]
                ]
            ]
        ])
    }
}

final class SearchPaginationTests: XCTestCase {
    func testBuildNone() throws {
        @ElasticSearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Pagination()
        }
        XCTAssertNoDifference(build().makeQuery(), [:])
    }
    func testBuildFirst() throws {
        @ElasticSearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Pagination(from: 10)
        }
        XCTAssertNoDifference(build().makeQuery(), [
            "from": 10
        ])
    }
    func testBuildFirstSize() throws {
        @ElasticSearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Pagination(from: 10, size: 20)
        }
        XCTAssertNoDifference(build().makeQuery(), [
            "from": 10,
            "size": 20,
        ])
    }
}
