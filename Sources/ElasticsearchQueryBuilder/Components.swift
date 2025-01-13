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

extension ArrayComponent {
    public func makeCompactArray() -> [QueryDict] {
        var value = self.makeArray()
        value.removeAll(where: \.isEmpty)
        return value
    }
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

public struct EmptyArrayComponent: ArrayComponent {
    public func makeArray() -> [QueryDict] { [] }
}

/// Namespace for `@ElasticsearchQueryBuilder` components
public enum esb {}

extension esb {

    /// The type of a top level query structure.
    ///
    /// Used with `@ElasticsearchQueryBuilder`
    public typealias QueryDSL = RootQueryable

    /// The type of an array sub-component of a query.
    ///
    /// Used to create a reusable function to fill in the
    /// body of another component.
    ///
    /// Used with `@QueryArrayBuilder`
    public typealias QueryArray = ArrayComponent

    /// An empty component, adding nothing to the query syntax.
    public struct Nothing: DictComponent {
        public init() {}
        public func makeDict() -> QueryDict {
            [:]
        }
    }

    /// Adds a `key` with any type of value to the query syntax.
    public struct Key: DictComponent {
        var key: String
        var value: QueryValue
        public init(_ key: String, _ value: QueryValue) {
            self.key = key
            self.value = value
        }
        public init(_ key: String, value: () -> QueryDict) {
            self.key = key
            self.value = .dict(value())
        }
        public func makeDict() -> QueryDict {
            switch self.value {
            case let .dict(value):
                if value.isEmpty {
                    return [:]
                } else {
                    return [ self.key : self.value ]
                }
            case let .array(value):
                if value.isEmpty {
                    return [:]
                } else {
                   return [ self.key : self.value ]
                }
            default:
                return [ self.key : self.value ]
            }
        }
    }

    /// Adds a block to the syntax.
    public struct Dict<Component: DictComponent>: DictComponent {
        var key: String
        var component: Component
        public init(_ key: String, @QueryDictBuilder component: () -> Component) {
            self.key = key
            self.component = component()
        }
        public func makeDict() -> QueryDict {
            let dict = self.component.makeDict()
            if dict.isEmpty {
                return [:]
            } else {
                return [ key : .dict(self.component.makeDict()) ]
            }
        }
    }

    /// Adds a `query` block to the syntax.
    public struct Query<Component: DictComponent>: DictComponent {
        var component: Component
        public init(@QueryDictBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeDict() -> QueryDict {
            let dict = self.component.makeDict()
            if dict.isEmpty {
                return [:]
            } else {
                return [ "query" : .dict(self.component.makeDict()) ]
            }
        }
    }

    /// Adds an `aggs` block to the syntax.
    public struct Aggs<Component: DictComponent>: DictComponent {
        var component: Component
        public init(@QueryDictBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeDict() -> QueryDict {
            let dict = self.component.makeDict()
            if dict.isEmpty {
                return [:]
            } else {
                return [ "aggs" : .dict(self.component.makeDict()) ]
            }
        }
    }

    /// Defines and named aggregate within `Aggs`
    public struct Agg: DictComponent {
        var name: String
        var term: QueryDict
        public init(_ name: String, field: String) {
            self.name = name
            self.term = [ "field" : .string(field) ]
        }
        public init(_ name: String, term: QueryDict) {
            self.name = name
            self.term = term
        }
        public func makeDict() -> QueryDict {
            return [ self.name : [ "terms" : .dict(self.term) ] ]
        }
    }

    /// Adds `minimum_should_match` to the query syntax.
    public struct MinimumShouldMatch: DictComponent {
        var count: Int
        public init(_ count: Int) {
            self.count = count
        }
        public func makeDict() -> QueryDict {
            [ "minimum_should_match" : .int(self.count) ]
        }
    }

    /// Adds `bool` block to the query syntax.
    public struct Bool<Component: DictComponent>: DictComponent {
        var component: Component
        public init(@QueryDictBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeDict() -> QueryDict {
            let dict = self.component.makeDict()
            if dict.isEmpty {
                return [:]
            } else {
                return [ "bool" : .dict(dict) ]
            }
        }
    }

    /// Adds `filter` block to the query syntax.
    public struct Filter<Component: ArrayComponent>: DictComponent {
        var component: Component
        public init(@QueryArrayBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeDict() -> QueryDict {
            let values: [QueryDict] = self.component.makeCompactArray()
            if values.isEmpty {
                return [:]
            } else {
                return [ "filter" :  .array(values.map(QueryValue.dict)) ]
            }
        }
    }

    /// Adds `should` block to the query syntax.
    public struct Should<Component: ArrayComponent>: DictComponent {
        var component: Component
        public init(@QueryArrayBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeDict() -> QueryDict {
            let values: [QueryDict] = self.component.makeCompactArray()
            if values.isEmpty {
                return [:]
            } else {
                return [ "should" :  .array(values.map(QueryValue.dict)) ]
            }
        }
    }

    /// Adds `must` block to the query syntax.
    public struct Must<Component: ArrayComponent>: DictComponent {
        var component: Component
        public init(@QueryArrayBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeDict() -> QueryDict {
            let values: [QueryDict] = self.component.makeCompactArray()
            if values.isEmpty {
                return [:]
            } else {
                return [ "must" :  .array(values.map(QueryValue.dict)) ]
            }
        }
    }

    /// Adds `must_not` block to the query syntax.
    public struct MustNot<Component: ArrayComponent>: DictComponent {
        var component: Component
        public init(@QueryArrayBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeDict() -> QueryDict {
            let values: [QueryDict] = self.component.makeCompactArray()
            if values.isEmpty {
                return [:]
            } else {
                return [ "must_not" :  .array(values.map(QueryValue.dict)) ]
            }
        }
    }

    /// Adds `sort` block to the query syntax.
    public struct Sort<Component: ArrayComponent>: DictComponent {
        var component: Component
        public init(@QueryArrayBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeDict() -> QueryDict {
            let values: [QueryDict] = self.component.makeCompactArray()
            if values.isEmpty {
                return [:]
            } else {
                return [ "sort" :  .array(values.map(QueryValue.dict)) ]
            }
        }
    }

    /// Adds `term` block to the query syntax.
    ///
    /// Excludes the component if value is nil.
    public struct Term: DictComponent {
        let field: String
        let value: String?
        public init(_ field: String, _ value: String?) {
            self.field = field
            self.value = value
        }
        public init<V: RawRepresentable>(_ field: String, _ value: V?) where V.RawValue == String {
            self.field = field
            self.value = value?.rawValue
        }
        public init<V: CustomStringConvertible>(_ field: String, describing value: V?) {
            self.field = field
            self.value = value?.description
        }
        public func makeDict() -> QueryDict {
            guard let value = self.value else { return [:] }
            return [ "term" :  [ self.field : .string(value) ] ]
        }
    }

    /// Adds multiple `term` block to the query syntax.
    ///
    /// Excludes the component if values is empty.
    public struct TermsAND: ArrayComponent {
        let field: String
        let values: [String]
        public init(_ field: String, _ values: [String]) {
            self.field = field
            self.values = values
        }
        public init<V>(_ field: String, _ values: [V]) where V: RawRepresentable, V.RawValue == String {
            self.field = field
            self.values = values.map(\.rawValue)
        }
        public init<V>(_ field: String, describing values: [V]) where V: CustomStringConvertible {
            self.field = field
            self.values = values.map(\.description)
        }
        public func makeArray() -> [QueryDict] {
            return self.values.map {
                [ "term" :  [ self.field : .string($0) ] ]
            }
        }
    }

    /// Adds a `terms` block to the query syntax.
    ///
    /// Excludes the component if values is empty.
    public struct TermsOR: DictComponent {
        let field: String
        let values: [String]
        public init(_ field: String, _ values: [String]) {
            self.field = field
            self.values = values
        }
        public init<V>(_ field: String, _ values: [V]) where V: RawRepresentable, V.RawValue == String {
            self.field = field
            self.values = values.map(\.rawValue)
        }
        public init<V>(_ field: String, describing values: [V]) where V: CustomStringConvertible {
            self.field = field
            self.values = values.map(\.description)
        }
        public func makeDict() -> QueryDict {
            if self.values.isEmpty {
                return [:]
            } else {
                return [ "terms" :  [ self.field : .array(self.values) ] ]
            }
        }
    }

    /// Adds `knn` block to the query syntax.
    public struct kNearestNeighbor<Component: ArrayComponent>: DictComponent {
        let field: String
        let vector: [Double]
        let options: QueryDict
        var filter: Component
        public init(
            _ field: String,
            _ vector: [Double],
            options: () -> QueryDict = { [:] },
            @QueryArrayBuilder filter: () -> Component
        ) {
            self.field = field
            self.vector = vector
            self.options = options()
            self.filter = filter()
        }
        public init(
            _ field: String,
            _ vector: [Double],
            options: () -> QueryDict = { [:] }
        ) where Component == EmptyArrayComponent {
            self.field = field
            self.vector = vector
            self.options = options()
            self.filter = EmptyArrayComponent()
        }
        public func makeDict() -> QueryDict {
            var dict: QueryDict = self.options
            dict["field"] = .string(self.field)
            dict["query_vector"] = .array(self.vector)
            let filterValues = self.filter.makeCompactArray()
            if !filterValues.isEmpty {
                dict["filter"] = .array(filterValues.map(QueryValue.dict))
            }
            return [ "knn" : .dict(dict) ]
        }
    }

    /// Adds `function_score` block to the query syntax.
    public struct FunctionScore<Component: DictComponent>: DictComponent {
        var component: Component
        public init(@QueryDictBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeDict() -> QueryDict {
            [ "function_score" : .dict(self.component.makeDict()) ]
        }
    }

    /// Adds `functions` block to the query syntax.
    public struct FunctionsList<Component: ArrayComponent>: DictComponent {
        var component: Component
        public init(@QueryArrayBuilder component: () -> Component) {
            self.component = component()
        }
        public func makeDict() -> QueryDict {
            let values: [QueryDict] = self.component.makeCompactArray()
            if values.isEmpty {
                return [:]
            } else {
                return [ "functions" :  .array(values.map(QueryValue.dict)) ]
            }
        }
    }

    /// Adds an element to a `FunctionsList` block to the query syntax.
    public struct Function: DictComponent {
        var function: QueryDict
        public init(function: () -> QueryDict) {
            self.function = function()
        }
        public func makeDict() -> QueryDict {
            self.function
        }
    }

    /// Adds a `boost` key to the query syntax.
    public struct Boost: DictComponent {
        let boost: Float
        public init(_ boost: Float) {
            self.boost = boost
        }
        public func makeDict() -> QueryDict {
            [ "boost": .float(self.boost) ]
        }
    }

    /// Adds a `boost_mode` key to the query syntax.
    public struct BoostMode: DictComponent {
        let mode: BoostModeType
        public init(_ mode: BoostModeType) {
            self.mode = mode
        }
        public func makeDict() -> QueryDict {
            [ "boost_mode": .string(self.mode.rawValue) ]
        }
    }

    /// Adds a `score_mode` key to the query syntax.
    public struct ScoreMode: DictComponent {
        let mode: ScoreModeType
        public init(_ mode: ScoreModeType) {
            self.mode = mode
        }
        public func makeDict() -> QueryDict {
            [ "score_mode": .string(self.mode.rawValue) ]
        }
    }

    /// Adds `from` and/or `size` keys to the query syntax.
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

public struct BoostModeType: RawRepresentable, Equatable, Sendable {
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

public struct ScoreModeType: RawRepresentable, Equatable, Sendable {
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
