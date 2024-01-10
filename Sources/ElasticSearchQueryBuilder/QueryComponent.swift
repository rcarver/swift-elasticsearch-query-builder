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

public struct MinimumShouldMatch: QueryComponent {
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

public struct PaginationQuery: QueryComponent {
    var first: Int?
    var size: Int?
    public init(first: Int? = nil, size: Int? = nil) {
        self.first = first
        self.size = size
    }
    public func makeValue() -> QueryDict {
        var dict = QueryDict()
        if let first = self.first {
            dict["first"] = .int(first)
        }
        if let size = self.size {
            dict["size"] = .int(size)
        }
        return dict
    }
}
