import CustomDump
import XCTest

@testable import ElasticsearchQueryBuilder

final class NothingTests: XCTestCase {
    func testBuild() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Nothing()
        }
        expectNoDifference(build().makeQuery(), [:])
    }
}

final class KeyTests: XCTestCase {
    func testBuildValue() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Key("boost", .float(1.2))
        }
        expectNoDifference(build().makeQuery(), [
            "boost": 1.2
        ])
    }
    func testBuildDict() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Key("match_bool_prefix") {
                [
                    "message": "quick brown f"
                ]
            }
        }
        expectNoDifference(build().makeQuery(), [
            "match_bool_prefix": [
                "message": "quick brown f"
            ]
        ])
    }
    func testBuildDictEmpty() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Key("match", .dict([:]))
        }
        expectNoDifference(build().makeQuery(), [:])
    }
}

final class DictTests: XCTestCase {
    func testBuildDict() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Dict("query") {
                esb.Key("match_bool_prefix") {
                    [
                        "message": "quick brown f"
                    ]
                }
            }
        }
        expectNoDifference(build().makeQuery(), [
            "query": [
                "match_bool_prefix": [
                    "message": "quick brown f"
                ]
            ]
        ])
    }
    func testBuildDictEmpty() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Dict("query") {
                esb.Key("match", .dict([:]))
            }
        }
        expectNoDifference(build().makeQuery(), [:])
    }
}

final class ComposableBuilderTests: XCTestCase {
    func testBuildDict() throws {
        @QueryDictBuilder func makeKey() -> some DictComponent {
            esb.Key("match_bool_prefix") {
                [
                    "message": "quick brown f"
                ]
            }
        }
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Query {
                makeKey()
            }
        }
        expectNoDifference(build().makeQuery(), [
            "query": [
                "match_bool_prefix": [
                    "message": "quick brown f"
                ]
            ]
        ])
    }
    func testBuildArray() throws {
        @QueryArrayBuilder func makeKey(_ isEnabled: Bool) -> some esb.QueryArray {
            if isEnabled {
                esb.Key("match_bool_prefix") {
                    [
                        "message": "quick brown f"
                    ]
                }
            }
        }
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Filter {
                makeKey(true)
            }
        }
        expectNoDifference(build().makeQuery(), [
            "filter": [
                [
                    "match_bool_prefix": [
                        "message": "quick brown f"
                    ]
                ]
            ]
        ])
    }
    func testBuildArray2() throws {
        @QueryArrayBuilder func makeKey(_ isEnabled: Bool, _ c: Int) -> esb.QueryArray {
            if isEnabled {
                esb.Key("match_bool_prefix") {
                    [
                        "message": .string("quick brown \(c)")
                    ]
                }
            }
        }
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Filter {
                makeKey(true, 1)
                makeKey(false, 2)
                makeKey(true, 3)
            }
        }
        expectNoDifference(build().makeQuery(), [
            "filter": [
                [
                    "match_bool_prefix": [
                        "message": "quick brown 1"
                    ]
                ],
                [
                    "match_bool_prefix": [
                        "message": "quick brown 3"
                    ]
                ]
            ]
        ])
    }
}

final class QueryTests: XCTestCase {
    func testBuild() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Query {
                esb.Key("match_bool_prefix") {
                    [
                        "message": "quick brown f"
                    ]
                }
            }
        }
        expectNoDifference(build().makeQuery(), [
            "query": [
                "match_bool_prefix": [
                    "message": "quick brown f"
                ]
            ]
        ])
    }
    func testBuildEmpty() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Query {
                esb.Key("match", .dict([:]))
            }
        }
        expectNoDifference(build().makeQuery(), [:])
    }
}

final class AggsTests: XCTestCase {
    func testBuild() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Aggs {
                esb.Agg("name", field: "name")
            }
        }
        expectNoDifference(build().makeQuery(), [
            "aggs": [
                "name": [
                    "terms": [ "field": "name" ]
                ]
            ]
        ])
    }
    func testBuildEmpty() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Aggs {
                esb.Key("name", .dict([:]))
            }
        }
        expectNoDifference(build().makeQuery(), [:])
    }
}

final class BoolTests: XCTestCase {
    func testBuild() throws {
        @ElasticsearchQueryBuilder func build(_ enabled: Bool) -> some esb.QueryDSL {
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
        expectNoDifference(build(true).makeQuery(), [
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
        expectNoDifference(build(false).makeQuery(), [
            "bool": [
                "minimum_should_match": 1
            ]
        ])
    }
    func testBuildEmpty() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
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
        expectNoDifference(build().makeQuery(), [:])
    }
}

final class SortTests: XCTestCase {
    func testBuild() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Sort {
                esb.Key("_score") {
                    [ "order": "desc" ]
                }
                esb.Key("name") {
                    [ "order": "asc" ]
                }
            }
        }
        expectNoDifference(build().makeQuery(), [
            "sort": [
                [
                    "_score": [ "order": "desc" ]
                ],
                [
                    "name": [ "order": "asc" ]
                ]
            ]
        ])
    }
    func testBuildEmpty() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Sort {
                if false {
                    esb.Key("_score") {
                        [ "order": "desc" ]
                    }
                }
            }
        }
        expectNoDifference(build().makeQuery(), [:])
    }
}

final class TermTests: XCTestCase {
    func testBuild() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Term("name", "joe")
        }
        expectNoDifference(build().makeQuery(), [
            "term": [ "name": "joe" ]
        ])
    }
    func testBuildEmpty() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Term("name", nil)
        }
        expectNoDifference(build().makeQuery(), [:])
    }
}

final class TermsORTests: XCTestCase {
    func testBuild() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.TermsOR("name", ["joe", "mary"])
        }
        expectNoDifference(build().makeQuery(), [
            "terms": [ "name": ["joe", "mary"] ]
        ])
    }
    func testBuildEmpty() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.TermsOR("name", [])
        }
        expectNoDifference(build().makeQuery(), [:])
    }
}

final class TermsANDTests: XCTestCase {
    func testBuild() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Filter {
                esb.TermsAND("name", ["joe", "mary"])
            }
        }
        expectNoDifference(build().makeQuery(), [
            "filter": [
                [ "term": [ "name": "joe" ] ],
                [ "term": [ "name": "mary" ] ],
            ]
        ])
    }
    func testBuildEmpty() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Filter {
                esb.TermsAND("name", [])
            }
        }
        expectNoDifference(build().makeQuery(), [:])
    }
}

final class KNearestNeighborTests: XCTestCase {
    func testBuildBasic() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.kNearestNeighbor("vector_field", [1,2,3])
        }
        expectNoDifference(build().makeQuery(), [
            "knn": [
                "field": "vector_field",
                "query_vector": [1.0, 2.0, 3.0],
            ]
        ])
    }
    func testBuildWithOptionsAndFilter() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.kNearestNeighbor("vector_field", [1,2,3]) {
                [
                    "k": 5,
                    "index": true
                ]
            } filter: {
                esb.Key("match_bool_prefix") {
                    [
                        "message": "quick brown f"
                    ]
                }
            }
        }
        expectNoDifference(build().makeQuery(), [
            "knn": [
                "field": "vector_field",
                "query_vector": [1.0, 2.0, 3.0],
                "k": 5,
                "index": true,
                "filter": [
                    [
                        "match_bool_prefix": [
                            "message": "quick brown f"
                        ]
                    ]
                ]
            ]
        ])
    }
}

final class FunctionScoreTests: XCTestCase {
    func testBuild() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
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
        expectNoDifference(build().makeQuery(), [
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
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Pagination()
        }
        expectNoDifference(build().makeQuery(), [:])
    }
    func testBuildFirst() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Pagination(from: 10)
        }
        expectNoDifference(build().makeQuery(), [
            "from": 10
        ])
    }
    func testBuildFirstSize() throws {
        @ElasticsearchQueryBuilder func build() -> some esb.QueryDSL {
            esb.Pagination(from: 10, size: 20)
        }
        expectNoDifference(build().makeQuery(), [
            "from": 10,
            "size": 20,
        ])
    }
}
