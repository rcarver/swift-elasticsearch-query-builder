import Foundation

public protocol RootQueryable {
    func makeQuery() -> QueryDict
}

public protocol QueryComponent<Value> {
    associatedtype Value
    func makeValue() -> Value
}

public struct RootComponent<Query: QueryComponent>: RootQueryable, QueryComponent where Query.Value == QueryDict {
    var query: Query
    public func makeValue() -> QueryDict {
        self.query.makeValue()
    }
    public func makeQuery() -> QueryDict {
        self.makeValue()
    }
}

public struct NoopComponent: QueryComponent {
    public init() {}
    public func makeValue() -> QueryDict {
        [:]
    }
}

/// Namespace for `@ElasticSearchQueryBuilder` components
public enum esb {}

extension esb {

    public typealias QueryDSL = RootQueryable

    public struct Query<Component: QueryComponent>: QueryComponent where Component.Value == QueryDict {
        var component: Component
        public init(@QueryDictBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeValue() -> QueryDict {
            [ "query" : .dict(self.component.makeValue()) ]
        }
    }

    public struct Dict: QueryComponent {
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

    public struct Value: QueryComponent {
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

    public struct MinimumShouldMatch: QueryComponent {
        var count: Int
        public init(_ count: Int) {
            self.count = count
        }
        public func makeValue() -> QueryDict {
            [ "minimum_should_match" : .int(self.count) ]
        }
    }

    public struct Bool<Component: QueryComponent>: QueryComponent where Component.Value == QueryDict {
        var component: Component
        public init(@QueryDictBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeValue() -> QueryDict {
            [ "bool" : .dict(self.component.makeValue()) ]
        }
    }

    public struct Filter<Component: QueryComponent>: QueryComponent where Component.Value == [QueryDict] {
        var component: Component
        public init(@QueryArrayBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeValue() -> QueryDict {
            [ "filter" : .array(self.component.makeValue().map(QueryValue.dict)) ]
        }
    }

    public struct Should<Component: QueryComponent>: QueryComponent where Component.Value == [QueryDict] {
        var component: Component
        public init(@QueryArrayBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeValue() -> QueryDict {
            [ "should" : .array(self.component.makeValue().map(QueryValue.dict)) ]
        }
    }

    public struct Must<Component: QueryComponent>: QueryComponent where Component.Value == [QueryDict] {
        var component: Component
        public init(@QueryArrayBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeValue() -> QueryDict {
            [ "must" : .array(self.component.makeValue().map(QueryValue.dict)) ]
        }
    }

    public struct MustNot<Component: QueryComponent>: QueryComponent where Component.Value == [QueryDict] {
        var component: Component
        public init(@QueryArrayBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeValue() -> QueryDict {
            [ "must_not" : .array(self.component.makeValue().map(QueryValue.dict)) ]
        }
    }

    public struct FunctionScore<Component: QueryComponent>: QueryComponent where Component.Value == QueryDict {
        var component: Component
        public init(@QueryDictBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeValue() -> QueryDict {
            [ "function_score" : .dict(self.component.makeValue()) ]
        }
    }

    public struct FunctionsList<Component: QueryComponent>: QueryComponent where Component.Value == [QueryDict] {
        var component: Component
        public init(@QueryArrayBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeValue() -> QueryDict {
            [ "functions" : .array(self.component.makeValue().map(QueryValue.dict)) ]
        }
    }

    public struct Function: QueryComponent {
        var function: QueryDict
        public init(function: () -> QueryDict) {
            self.function = function()
        }
        public func makeValue() -> QueryDict {
            self.function
        }
    }

    public struct Boost: QueryComponent {
        let boost: Float
        public init(_ boost: Float) {
            self.boost = boost
        }
        public func makeValue() -> QueryDict {
            [ "boost": .float(self.boost) ]
        }
    }

    public struct BoostMode: QueryComponent {
        let mode: BoostModeType
        public init(_ mode: BoostModeType) {
            self.mode = mode
        }
        public func makeValue() -> QueryDict {
            [ "boost_mode": .string(self.mode.rawValue) ]
        }
    }

    public struct ScoreMode: QueryComponent {
        let mode: ScoreModeType
        public init(_ mode: ScoreModeType) {
            self.mode = mode
        }
        public func makeValue() -> QueryDict {
            [ "score_mode": .string(self.mode.rawValue) ]
        }
    }

    public struct Pagination: QueryComponent, Equatable {
        public var from: Int?
        public var size: Int?
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
}

public struct BoostModeType: RawRepresentable, Equatable {
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

public struct ScoreModeType: RawRepresentable, Equatable {
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
