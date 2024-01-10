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
                DictQuery("match_bool_prefix") {
                    [
                        "message": "quick brown f"
                    ]
                }
            }
        }
        XCTAssertNoDifference(build().makeQuery(), [
            "query": [
                "bool": [
                    "match_bool_prefix": [
                        "message": "quick brown f"
                    ]
                ]
            ]
        ])
    }
}

final class ShouldQueryTests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build() -> some ElasticSearchQuery {
            BoolQuery {
                ShouldQuery {
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
                    "should": [
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

final class MustQueryTests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build() -> some ElasticSearchQuery {
            BoolQuery {
                MustQuery {
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
                    "must": [
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

final class MustNotQueryTests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build() -> some ElasticSearchQuery {
            BoolQuery {
                MustNotQuery {
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
                    "must_not": [
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

final class MinimumShouldMatchQueryTests: XCTestCase {
    func testBuild() throws {
        @ElasticSearchQueryBuilder func build() -> some ElasticSearchQuery {
            BoolQuery {
                MinimumShouldMatchQuery(10)
            }
        }
        XCTAssertNoDifference(build().makeQuery(), [
            "query": [
                "bool": [
                    "minimum_should_match": 10
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
            PaginationQuery(first: 10)
        }
        XCTAssertNoDifference(build().makeQuery(), [
            "query": [
                "first": 10
            ]
        ])
    }
    func testBuildFirstSize() throws {
        @ElasticSearchQueryBuilder func build() -> some ElasticSearchQuery {
            PaginationQuery(first: 10, size: 20)
        }
        XCTAssertNoDifference(build().makeQuery(), [
            "query": [
                "first": 10,
                "size": 20,
            ]
        ])
    }
}
