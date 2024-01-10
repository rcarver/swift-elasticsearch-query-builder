import CustomDump
import XCTest

@testable import ElasticSearchQueryBuilder

final class DictQueryTests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build() -> some ElasticSearchQuery {
            DictQuery("match_bool_prefix") {
                [
                    "message": "quick brown f"
                ]
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

final class ValueQueryTests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build() -> some ElasticSearchQuery {
            ValueQuery("boost", .float(1.2))
        }
        XCTAssertNoDifference(build().makeQuery(), [
            "query": [
                "boost": 1.2
            ]
        ])
    }
}

final class BoolQueryTests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build() -> some ElasticSearchQuery {
            BoolQuery {
                MinimumShouldMatchQuery(1)
                ShouldQuery {
                    DictQuery("match_bool_prefix") {
                        [
                            "message": "quick brown f"
                        ]
                    }
                }
                MustQuery {
                    DictQuery("match_bool_prefix") {
                        [
                            "message": "quick brown f"
                        ]
                    }
                }
                MustNotQuery {
                    DictQuery("match_bool_prefix") {
                        [
                            "message": "quick brown f"
                        ]
                    }
                }
                FilterQuery {
                    DictQuery("match_bool_prefix") {
                        [
                            "message": "quick brown f"
                        ]
                    }
                }
            }
        }
        XCTAssertNoDifference(build().makeQuery(), [
            "query": [
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
            ]
        ])
    }
}

final class FilterQueryTests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build() -> some ElasticSearchQuery {
            BoolQuery {
                FilterQuery {
                    DictQuery("match_bool_prefix") {
                        [
                            "message": "quick brown f"
                        ]
                    }
                }
            }
        }
        XCTAssertNoDifference(build().makeQuery(), [
            "query": [
                "bool": [
                    "filter": [
                        [
                            "match_bool_prefix": [
                                "message": "quick brown f"
                            ]
                        ]
                    ]
                ]
            ]
        ])
    }
}

final class FunctionScoreQueryTests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build() -> some ElasticSearchQuery {
            FunctionScoreQuery() {
                BoolQuery {
                    ShouldQuery {
                        DictQuery("match_bool_prefix") {
                            [
                                "message": "quick brown f"
                            ]
                        }
                    }
                }
                BoostQuery(3.2)
                BoostModeQuery(.sum)
                ScoreModeQuery(.avg)
                FunctionsListQuery {
                    FunctionQuery {
                        [
                            "filter": [ "match": [ "test": "cat" ] ],
                            "weight": 42
                        ]
                    }
                }
            }
        }
        XCTAssertNoDifference(build().makeQuery(), [
            "query": [
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
            ]
        ])
    }
}

final class PaginationQueryTests: XCTestCase {
    func testBuildNone() throws {
        @ElasticSearchQueryBuilder func build() -> some ElasticSearchQuery {
            PaginationQuery()
        }
        XCTAssertNoDifference(build().makeQuery(), [
            "query": [:]
        ])
    }
    func testBuildFirst() throws {
        @ElasticSearchQueryBuilder func build() -> some ElasticSearchQuery {
            PaginationQuery(from: 10)
        }
        XCTAssertNoDifference(build().makeQuery(), [
            "query": [
                "from": 10
            ]
        ])
    }
    func testBuildFirstSize() throws {
        @ElasticSearchQueryBuilder func build() -> some ElasticSearchQuery {
            PaginationQuery(from: 10, size: 20)
        }
        XCTAssertNoDifference(build().makeQuery(), [
            "query": [:],
            "from": 10,
            "size": 20,
        ])
    }
}
