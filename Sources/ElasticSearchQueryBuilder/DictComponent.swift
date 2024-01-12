import Foundation

public protocol RootQueryable {
    func makeQuery() -> QueryDict
}

public protocol DictComponent {
    func makeDict() -> QueryDict
}

public protocol ArrayComponent {
    func makeArray() -> [QueryDict]
}

public struct RootComponent<Component: DictComponent>: RootQueryable, DictComponent {
    var component: Component
    public func makeDict() -> QueryDict {
        self.component.makeDict()
    }
    public func makeQuery() -> QueryDict {
        self.makeDict()
    }
}

/// Namespace for `@ElasticSearchQueryBuilder` components
public enum esb {}

extension esb {

    public typealias QueryDSL = RootQueryable

    public struct None: DictComponent {
        public init() {}
        public func makeDict() -> QueryDict {
            [:]
        }
    }

    public struct Query<Component: DictComponent>: DictComponent {
        var component: Component
        public init(@QueryDictBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeDict() -> QueryDict {
            [ "query" : .dict(self.component.makeDict()) ]
        }
    }

    public struct Dict: DictComponent {
        var key: String
        var value: QueryDict
        public init(_ key: String, value: () -> QueryDict) {
            self.key = key
            self.value = value()
        }
        public func makeDict() -> QueryDict {
            [ self.key : .dict(self.value) ]
        }
    }

    public struct Value: DictComponent {
        var key: String
        var value: QueryValue
        public init(_ key: String, _ value:  QueryValue) {
            self.key = key
            self.value = value
        }
        public func makeDict() -> QueryDict {
            [ self.key : self.value ]
        }
    }

    public struct MinimumShouldMatch: DictComponent {
        var count: Int
        public init(_ count: Int) {
            self.count = count
        }
        public func makeDict() -> QueryDict {
            [ "minimum_should_match" : .int(self.count) ]
        }
    }

    public struct Bool<Component: DictComponent>: DictComponent {
        var component: Component
        public init(@QueryDictBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeDict() -> QueryDict {
            [ "bool" : .dict(self.component.makeDict()) ]
        }
    }

    public struct Filter<Component: ArrayComponent>: DictComponent {
        var component: Component
        public init(@QueryArrayBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeDict() -> QueryDict {
            let values: [QueryDict] = self.component.makeArray()
            if values.isEmpty {
                return [:]
            } else {
                return [ "filter" :  .array(values.map(QueryValue.dict)) ]
            }
        }
    }

    public struct Should<Component: ArrayComponent>: DictComponent {
        var component: Component
        public init(@QueryArrayBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeDict() -> QueryDict {
            let values: [QueryDict] = self.component.makeArray()
            if values.isEmpty {
                return [:]
            } else {
                return [ "should" :  .array(values.map(QueryValue.dict)) ]
            }
        }
    }

    public struct Must<Component: ArrayComponent>: DictComponent {
        var component: Component
        public init(@QueryArrayBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeDict() -> QueryDict {
            let values: [QueryDict] = self.component.makeArray()
            if values.isEmpty {
                return [:]
            } else {
                return [ "must" :  .array(values.map(QueryValue.dict)) ]
            }
        }
    }

    public struct MustNot<Component: ArrayComponent>: DictComponent {
        var component: Component
        public init(@QueryArrayBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeDict() -> QueryDict {
            let values: [QueryDict] = self.component.makeArray()
            if values.isEmpty {
                return [:]
            } else {
                return [ "must_not" :  .array(values.map(QueryValue.dict)) ]
            }
        }
    }

    public struct FunctionScore<Component: DictComponent>: DictComponent {
        var component: Component
        public init(@QueryDictBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeDict() -> QueryDict {
            [ "function_score" : .dict(self.component.makeDict()) ]
        }
    }

    public struct FunctionsList<Component: ArrayComponent>: DictComponent {
        var component: Component
        public init(@QueryArrayBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeDict() -> QueryDict {
            [ "functions" : .array(self.component.makeArray().map(QueryValue.dict)) ]
        }
    }

    public struct Function: DictComponent {
        var function: QueryDict
        public init(function: () -> QueryDict) {
            self.function = function()
        }
        public func makeDict() -> QueryDict {
            self.function
        }
    }

    public struct Boost: DictComponent {
        let boost: Float
        public init(_ boost: Float) {
            self.boost = boost
        }
        public func makeDict() -> QueryDict {
            [ "boost": .float(self.boost) ]
        }
    }

    public struct BoostMode: DictComponent {
        let mode: BoostModeType
        public init(_ mode: BoostModeType) {
            self.mode = mode
        }
        public func makeDict() -> QueryDict {
            [ "boost_mode": .string(self.mode.rawValue) ]
        }
    }

    public struct ScoreMode: DictComponent {
        let mode: ScoreModeType
        public init(_ mode: ScoreModeType) {
            self.mode = mode
        }
        public func makeDict() -> QueryDict {
            [ "score_mode": .string(self.mode.rawValue) ]
        }
    }

    public struct Pagination: DictComponent, Equatable {
        public var from: Int?
        public var size: Int?
        public init(from: Int? = nil, size: Int? = nil) {
            self.from = from
            self.size = size
        }
        public func makeDict() -> QueryDict {
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
