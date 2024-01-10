import Foundation

@resultBuilder
struct QueryBuilder {
    static func buildBlock() -> NoopQuery {
        NoopQuery()
    }
    static func buildBlock<C: QueryComponent>(_ component: C) -> C {
        component
    }
    static func buildBlock<C0, C1>(_ c0: C0, _ c1: C1) -> Merge<C0, C1> {
        .init(a: c0, b: c1)
    }
    static func buildBlock<C0, C1, C2>(_ c0: C0, _ c1: C1, _ c2: C2) -> Merge<C0, Merge<C1, C2>> {
        .init(a: c0, b: .init(a: c1, b: c2))
    }
    public static func buildIf<C: QueryComponent>(_ c: C?) -> OptionalVoid<C> {
        .init(wrapped: c)
    }
    struct Merge<A: QueryComponent, B: QueryComponent>: QueryComponent {
        var a: A
        var b: B
        func makeData() -> QueryDict {
            var data: QueryDict = [:]
            for (k, v) in self.a.makeData() {
                data[k] = v
            }
            for (k, v) in self.b.makeData() {
                data[k] = v
            }
            return data
        }
    }
    struct OptionalVoid<Wrapped: QueryComponent>: QueryComponent {
        let wrapped: Wrapped?
        func makeData() -> QueryDict {
            guard let wrapped = self.wrapped
            else { return [:] }
            return wrapped.makeData()
        }
    }
}

protocol QueryComponent {
    func makeData() -> QueryDict
}

struct NoopQuery: QueryComponent {
    func makeData() -> QueryDict {
        [:]
    }
}

struct DictQuery: QueryComponent {
    var key: String
    var data: QueryDict
    init(_ key: String, data: () -> QueryDict) {
        self.key = key
        self.data = data()
    }
    func makeData() -> QueryDict {
        [ self.key : .dict(self.data) ]
    }
}

struct ElasticSearchQuery<Component: QueryComponent>: QueryComponent {
    var component: Component
    init(@QueryBuilder component: () -> Component) {
        self.component = component()
    }
    func makeData() -> QueryDict {
        [ "query" : .dict(self.component.makeData()) ]
    }
}

struct MinimumShouldMatch: QueryComponent {
    var count: Int
    init(_ count: Int) {
        self.count = count
    }
    func makeData() -> QueryDict {
        [ "minimum_should_match" : .int(self.count) ]
    }
}

struct BoolQuery<Component: QueryComponent>: QueryComponent {
    var component: Component
    init(@QueryBuilder component: () -> Component) {
        self.component = component()
    }
    func makeData() -> QueryDict {
        [ "bool" : .dict(self.component.makeData()) ]
    }
}

struct FilterQuery<Component: QueryComponent>: QueryComponent {
    var component: Component
    init(@QueryBuilder component: () -> Component) {
        self.component = component()
    }
    func makeData() -> QueryDict {
        [ "filter" : .dict(self.component.makeData()) ]
    }
}

struct ShouldQuery<Component: QueryComponent>: QueryComponent {
    var component: Component
    init(@QueryBuilder component: () -> Component) {
        self.component = component()
    }
    func makeData() -> QueryDict {
        [ "should" : .dict(self.component.makeData()) ]
    }
}

struct MustQuery<Component: QueryComponent>: QueryComponent {
    var component: Component
    init(@QueryBuilder component: () -> Component) {
        self.component = component()
    }
    func makeData() -> QueryDict {
        [ "must" : .dict(self.component.makeData()) ]
    }
}

struct PaginationQuery: QueryComponent {
    var first: Int?
    var size: Int?
    func makeData() -> QueryDict {
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
