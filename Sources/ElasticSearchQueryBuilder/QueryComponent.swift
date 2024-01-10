import Foundation

public typealias ElasticSearchQuery = QueryComponent<QueryDict>

public protocol QueryComponent<Value> {
    associatedtype Value
    func makeValue() -> Value
}

extension QueryComponent where Value == QueryDict {
    public func makeQuery() -> QueryDict {
        [ "query" : .dict(self.makeValue()) ]
    }
}

public struct NoopQuery: QueryComponent {
    public init() {}
    public func makeValue() -> QueryDict {
        [:]
    }
}

public struct DictQuery: QueryComponent {
    var key: String
    var value: QueryDict
    public init(_ key: String, value: () -> QueryDict) {
        self.key = key
        self.value = value()
    }
    public func makeValue() -> QueryDict {
        [ self.key : .dict(self.value) ]
    }
}

public struct ValueQuery: QueryComponent {
    var key: String
    var value: QueryValue
    public init(_ key: String, _ value:  QueryValue) {
        self.key = key
        self.value = value
    }
    public func makeValue() -> QueryDict {
        [ self.key : self.value ]
    }
}

public struct MinimumShouldMatchQuery: QueryComponent {
    var count: Int
    public init(_ count: Int) {
        self.count = count
    }
    public func makeValue() -> QueryDict {
        [ "minimum_should_match" : .int(self.count) ]
    }
}

public struct BoolQuery<Component: QueryComponent>: QueryComponent where Component.Value == QueryDict {
    var component: Component
    public init(@QueryDictBuilder component: () -> Component) {
        self.component = component()
    }
    public func makeValue() -> QueryDict {
        [ "bool" : .dict(self.component.makeValue()) ]
    }
}

public struct FilterQuery<Component: QueryComponent>: QueryComponent where Component.Value == [QueryDict] {
    var component: Component
    public init(@QueryArrayBuilder component: () -> Component) {
        self.component = component()
    }
    public func makeValue() -> QueryDict {
        [ "filter" : .array(self.component.makeValue().map(QueryValue.dict)) ]
    }
}

public struct ShouldQuery<Component: QueryComponent>: QueryComponent where Component.Value == [QueryDict] {
    var component: Component
    public init(@QueryArrayBuilder component: () -> Component) {
        self.component = component()
    }
    public func makeValue() -> QueryDict {
        [ "should" : .array(self.component.makeValue().map(QueryValue.dict)) ]
    }
}

public struct MustQuery<Component: QueryComponent>: QueryComponent where Component.Value == [QueryDict] {
    var component: Component
    public init(@QueryArrayBuilder component: () -> Component) {
        self.component = component()
    }
    public func makeValue() -> QueryDict {
        [ "must" : .array(self.component.makeValue().map(QueryValue.dict)) ]
    }
}

public struct MustNotQuery<Component: QueryComponent>: QueryComponent where Component.Value == [QueryDict] {
    var component: Component
    public init(@QueryArrayBuilder component: () -> Component) {
        self.component = component()
    }
    public func makeValue() -> QueryDict {
        [ "must_not" : .array(self.component.makeValue().map(QueryValue.dict)) ]
    }
}

public struct FunctionScoreQuery<Component: QueryComponent>: QueryComponent where Component.Value == QueryDict {
    var component: Component
    public init(@QueryDictBuilder component: () -> Component) {
        self.component = component()
    }
    public func makeValue() -> QueryDict {
        [ "function_score" : .dict(self.component.makeValue()) ]
    }
}

public struct FunctionsListQuery<Component: QueryComponent>: QueryComponent where Component.Value == [QueryDict] {
    var component: Component
    public init(@QueryArrayBuilder component: () -> Component) {
        self.component = component()
    }
    public func makeValue() -> QueryDict {
        [ "functions" : .array(self.component.makeValue().map(QueryValue.dict)) ]
    }
}

public struct FunctionQuery: QueryComponent {
    var function: QueryDict
    public init(function: () -> QueryDict) {
        self.function = function()
    }
    public func makeValue() -> QueryDict {
        self.function
    }
}

public struct BoostQuery: QueryComponent {
    let boost: Float
    public init(_ boost: Float) {
        self.boost = boost
    }
    public func makeValue() -> QueryDict {
        [ "boost": .float(self.boost) ]
    }
}

public struct BoostMode: RawRepresentable, Equatable {
    public var rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    public static let multiply = Self(rawValue: "multiply")
    public static let replace = Self(rawValue: "replace")
    public static let sum = Self(rawValue: "sum")
    public static let avg = Self(rawValue: "avg")
    public static let max = Self(rawValue: "max")
    public static let min = Self(rawValue: "min")
}

public struct BoostModeQuery: QueryComponent {
    let mode: BoostMode
    public init(_ mode: BoostMode) {
        self.mode = mode
    }
    public func makeValue() -> QueryDict {
        [ "boost_mode": .string(self.mode.rawValue) ]
    }
}

public struct ScoreMode: RawRepresentable, Equatable {
    public var rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    public static let multiply = Self(rawValue: "multiply")
    public static let sum = Self(rawValue: "sum")
    public static let avg = Self(rawValue: "avg")
    public static let first = Self(rawValue: "first")
    public static let max = Self(rawValue: "max")
    public static let min = Self(rawValue: "min")
}

public struct ScoreModeQuery: QueryComponent {
    let mode: ScoreMode
    public init(_ mode: ScoreMode) {
        self.mode = mode
    }
    public func makeValue() -> QueryDict {
        [ "score_mode": .string(self.mode.rawValue) ]
    }
}

public struct PaginationQuery: QueryComponent {
    var from: Int?
    var size: Int?
    public init(from: Int? = nil, size: Int? = nil) {
        self.from = from
        self.size = size
    }
    public func makeValue() -> QueryDict {
        var dict = QueryDict()
        if let from = self.from {
            dict["from"] = .int(from)
        }
        if let size = self.size {
            dict["size"] = .int(size)
        }
        return dict
    }
}
