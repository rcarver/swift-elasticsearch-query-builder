import Foundation

public typealias ElasticSearchQueryBuilder = QueryDictBuilder

@resultBuilder
public struct QueryDictBuilder {
    public static func buildBlock<C: QueryComponent>(_ c: C) -> OneDict<C> {
        .init(c0: c)
    }
    public static func buildPartialBlock<C: QueryComponent>(first: C) -> C {
        first
    }
    public static func buildPartialBlock<C0, C1>(accumulated: C0, next: C1) -> MergeDicts<C0, C1> {
        .init(c0: accumulated, c1: next)
    }
    public static func buildIf<C>(_ c: C?) -> OptionalDict<C> {
        .init(wrapped: c)
    }
}

@resultBuilder
public struct QueryArrayBuilder {
    public static func buildBlock<C: QueryComponent>(_ c: C) -> AppendArray<C> {
        .init(wrapped: [c])
    }
    public static func buildPartialBlock<C: QueryComponent>(first: AppendArray<C>) -> AppendArray<C> {
        first
    }
    public static func buildPartialBlock<C: QueryComponent>(first: C) -> AppendArray<C> {
        .init(wrapped: [first])
    }
    public static func buildPartialBlock<C: QueryComponent>(first: OptionalArray<C>) -> AppendArray<C> {
        .init(wrapped: first.wrapped?.wrapped ?? [])
    }
    public static func buildPartialBlock<C: QueryComponent>(accumulated: AppendArray<C>, next: C)
    -> AppendArray<C> {
        .init(wrapped: accumulated.wrapped + [next])
    }
    public static func buildIf<C>(_ c: AppendArray<C>?) -> OptionalArray<C> {
        .init(wrapped: c)
    }
    public static func buildArray<C>(_ components: [AppendArray<C>]) -> AppendArray<C> {
        .init(wrapped: components.flatMap(\.wrapped))
    }
}

public struct OneDict<C0: QueryComponent>: QueryComponent
where C0.Value == QueryDict {
    var c0: C0
    public func makeValue() -> QueryDict {
        self.c0.makeValue()
    }
}

public struct MergeDicts<C0: QueryComponent, C1: QueryComponent>: QueryComponent
where C0.Value == QueryDict, C1.Value == QueryDict {
    var c0: C0
    var c1: C1
    public func makeValue() -> QueryDict {
        var data: QueryDict = [:]
        for (k, v) in self.c0.makeValue() {
            data[k] = v
        }
        for (k, v) in self.c1.makeValue() {
            data[k] = v
        }
        return data
    }
}

public struct OptionalDict<C: QueryComponent>: QueryComponent
where C.Value == QueryDict {
    let wrapped: C?
    public func makeValue() -> QueryDict {
        guard let wrapped = self.wrapped
        else { return [:] }
        return wrapped.makeValue()
    }
}

public struct AppendArray<C: QueryComponent>: QueryComponent {
    var wrapped: [C]
    public func makeValue() -> [C.Value] {
        self.wrapped.map { $0.makeValue() }
    }
}

public struct OptionalArray<C: QueryComponent>: QueryComponent {
    let wrapped: AppendArray<C>?
    public func makeValue() -> [C.Value] {
        guard let wrapped = self.wrapped
        else { return [] }
        return wrapped.makeValue()
    }
}