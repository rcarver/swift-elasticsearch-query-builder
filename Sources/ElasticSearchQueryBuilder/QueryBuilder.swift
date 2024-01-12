import Foundation

@resultBuilder
public struct ElasticSearchQueryBuilder {
    public static func buildPartialBlock<C: QueryComponent>(first: C) -> RootComponent<C> {
        .init(query: first)
    }
    public static func buildPartialBlock<C0, C1>(accumulated: RootComponent<C0>, next: C1) -> RootComponent<MergeDicts<C0, C1>> {
        .init(query: .init(c0: accumulated.query, c1: next))
    }
    public static func buildIf<C>(_ c: C?) -> RootComponent<OptionalDict<C>> {
        .init(query: .init(wrapped: c))
    }
}

@resultBuilder
public struct QueryDictBuilder {
    public static func buildPartialBlock<C: QueryComponent>(first: C) -> C {
        first
    }
    public static func buildPartialBlock<C0, C1>(accumulated: C0, next: C1) -> MergeDicts<C0, C1> {
        .init(c0: accumulated, c1: next)
    }
    public static func buildIf<C>(_ c: C?) -> OptionalDict<C> {
        .init(wrapped: c)
    }
    public static func buildEither<TrueC, FalseC>(first c: TrueC) -> ConditionalDict<TrueC, FalseC> {
        .first(c)
    }
    public static func buildEither<TrueC, FalseC>(second c: FalseC) -> ConditionalDict<TrueC, FalseC> {
        .second(c)
    }
}

@resultBuilder
public struct QueryArrayBuilder {

    public static func buildPartialBlock<C: QueryComponent>(first: C) -> AppendArray<C> {
        .init(wrapped: [first])
    }
    public static func buildPartialBlock<C: QueryComponent>(first: AppendArray<C>) -> AppendArray<C> {
        first
    }

    public static func buildPartialBlock<C: QueryComponent>(accumulated: AppendArray<C>, next: C) -> AppendArray<C> {
        .init(wrapped: accumulated.wrapped + [next])
    }
    public static func buildPartialBlock<C: QueryComponent>(accumulated: AppendArray<C>, next: AppendArray<C>) -> AppendArray<C> {
        .init(wrapped: accumulated.wrapped + next.wrapped)
    }

    public static func buildIf<C>(_ c: AppendArray<C>?) -> AppendArray<C> {
        .init(wrapped: c?.wrapped ?? [])
    }

    public static func buildEither<C>(first c: C) -> C {
        c
    }
    public static func buildEither<C>(second c: C) -> C {
        c
    }

    public static func buildArray<C>(_ components: [AppendArray<C>]) -> AppendArray<C> {
        .init(wrapped: components.flatMap(\.wrapped))
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

public enum ConditionalDict<First: QueryComponent, Second: QueryComponent>: QueryComponent
where First.Value == Second.Value {
    case first(First)
    case second(Second)
    public func makeValue() -> First.Value {
        switch self {
        case let .first(first): first.makeValue()
        case let .second(second): second.makeValue()
        }
    }
}

public struct AppendArray<C: QueryComponent>: QueryComponent {
    var wrapped: [C]
    public func makeValue() -> [C.Value] {
        self.wrapped.map { $0.makeValue() }
    }
}
