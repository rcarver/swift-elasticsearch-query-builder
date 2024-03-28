import Foundation

@resultBuilder
public struct ElasticsearchQueryBuilder {
    public static func buildPartialBlock<C: DictComponent>(first: C) -> RootComponent<C> {
        .init(component: first)
    }
    public static func buildPartialBlock<C0, C1>(accumulated: RootComponent<C0>, next: C1) -> RootComponent<MergedDict<C0, C1>> {
        .init(component: .init(c0: accumulated.component, c1: next))
    }
    public static func buildIf<C>(_ c: C?) -> RootComponent<OptionalDict<C>> {
        .init(component: .init(wrapped: c))
    }
}

@resultBuilder
public struct QueryDictBuilder {
    public static func buildPartialBlock<C: DictComponent>(first: C) -> C {
        first
    }
    public static func buildPartialBlock<C0, C1>(accumulated: C0, next: C1) -> MergedDict<C0, C1> {
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

    public static func buildPartialBlock<C: ArrayComponent>(first: C) -> AppendDictValues {
        .init(wrapped: first.makeArray())
    }
    public static func buildPartialBlock<C: DictComponent>(first: C) -> AppendDictValues {
        .init(wrapped: [first.makeDict()])
    }
    public static func buildPartialBlock(first: AppendDictValues) -> AppendDictValues {
        first
    }

    public static func buildPartialBlock<C: ArrayComponent>(accumulated: AppendDictValues, next: C) -> AppendDictValues {
        .init(wrapped: accumulated.wrapped + next.makeArray())
    }
    public static func buildPartialBlock<C: DictComponent>(accumulated: AppendDictValues, next: C) -> AppendDictValues {
        .init(wrapped: accumulated.wrapped + [next.makeDict()])
    }
    public static func buildPartialBlock(accumulated: AppendDictValues, next: AppendDictValues) -> AppendDictValues {
        .init(wrapped: accumulated.wrapped + next.wrapped)
    }

    public static func buildIf(_ c: AppendDictValues?) -> AppendDictValues {
        .init(wrapped: c?.wrapped ?? [])
    }

    public static func buildEither<C>(first c: C) -> C {
        c
    }
    public static func buildEither<C>(second c: C) -> C {
        c
    }

    public static func buildArray(_ components: [AppendDictValues]) -> AppendDictValues {
        .init(wrapped: components.flatMap(\.wrapped))
    }
}

/// This is a properly typed resultBuilder but doesn't support heterogeneous collections
@resultBuilder
public struct QueryArrayBuilder_Typed {

    public static func buildPartialBlock<C: DictComponent>(first: C) -> AppendDictComponents<C> {
        .init(wrapped: [first])
    }
    public static func buildPartialBlock<C: DictComponent>(first: AppendDictComponents<C>) -> AppendDictComponents<C> {
        first
    }

    public static func buildPartialBlock<C: DictComponent>(accumulated: AppendDictComponents<C>, next: C) -> AppendDictComponents<C> {
        .init(wrapped: accumulated.wrapped + [next])
    }
    public static func buildPartialBlock<C: DictComponent>(accumulated: AppendDictComponents<C>, next: AppendDictComponents<C>) -> AppendDictComponents<C> {
        .init(wrapped: accumulated.wrapped + next.wrapped)
    }

    public static func buildIf<C>(_ c: AppendDictComponents<C>?) -> AppendDictComponents<C> {
        .init(wrapped: c?.wrapped ?? [])
    }

    public static func buildEither<C>(first c: C) -> C {
        c
    }
    public static func buildEither<C>(second c: C) -> C {
        c
    }

    public static func buildArray<C>(_ components: [AppendDictComponents<C>]) -> AppendDictComponents<C> {
        .init(wrapped: components.flatMap(\.wrapped))
    }
}

public struct MergedDict<C0: DictComponent, C1: DictComponent>: DictComponent {
    var c0: C0
    var c1: C1
    public func makeDict() -> QueryDict {
        var data: QueryDict = [:]
        for (k, v) in self.c0.makeDict() {
            data[k] = v
        }
        for (k, v) in self.c1.makeDict() {
            data[k] = v
        }
        return data
    }
}

public struct OptionalDict<C: DictComponent>: DictComponent {
    let wrapped: C?
    public func makeDict() -> QueryDict {
        guard let wrapped = self.wrapped
        else { return [:] }
        return wrapped.makeDict()
    }
}

public enum ConditionalDict<First: DictComponent, Second: DictComponent>: DictComponent {
    case first(First)
    case second(Second)
    public func makeDict() -> QueryDict {
        switch self {
        case let .first(first): first.makeDict()
        case let .second(second): second.makeDict()
        }
    }
}

public struct AppendDictComponents<C: DictComponent>: ArrayComponent {
    var wrapped: [C]
    public func makeArray() -> [QueryDict] {
        self.wrapped.map { $0.makeDict() }
    }
}

public struct AppendDictValues: ArrayComponent {
    var wrapped: [QueryDict]
    public func makeArray() -> [QueryDict] {
        self.wrapped
    }
}
