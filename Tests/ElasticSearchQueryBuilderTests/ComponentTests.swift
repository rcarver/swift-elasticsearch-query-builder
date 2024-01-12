import CustomDump
import XCTest

@testable import ElasticSearchQueryBuilder

final class NoneTests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.None()
        }
        XCTAssertNoDifference(build().makeQuery(), [:])
    }
}

final class DictTests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Dict("match_bool_prefix") {
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
}

final class ValueTests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Value("boost", .float(1.2))
        }
        XCTAssertNoDifference(build().makeQuery(), [
            "boost": 1.2
        ])
    }
}

final class QueryTests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Query {
                esb.Dict("match_bool_prefix") {
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
}

final class BoolTests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build(_ enabled: Bool) -> some esb.QueryDSL {
            esb.Bool {
                esb.MinimumShouldMatch(1)
                esb.Should {
                    if enabled {
                        esb.Dict("match_bool_prefix") {
                            [
                                "message": "quick brown f"
                            ]
                        }
                    }
                }
                esb.Must {
                    if enabled {
                        esb.Dict("match_bool_prefix") {
                            [
                                "message": "quick brown f"
                            ]
                        }
                    }
                }
                esb.MustNot {
                    if enabled {
                        esb.Dict("match_bool_prefix") {
                            [
                                "message": "quick brown f"
                            ]
                        }
                    }
                }
                esb.Filter {
                    if enabled {
                        esb.Dict("match_bool_prefix") {
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
}

final class FunctionScoreTests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.FunctionScore {
                esb.Bool {
                    esb.Should {
                        esb.Dict("match_bool_prefix") {
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
