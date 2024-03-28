import Foundation

public typealias QueryDict = [ String : QueryValue ]

public enum QueryValue: Equatable {
    case array([QueryValue])
    case bool(Bool)
    case date(Date, format: QueryDateFormat)
    case dict(QueryDict)
    case float(Float)
    case int(Int)
    case string(String)
}

public enum QueryDateFormat {
    /// Encode the `Date` as a UNIX timestamp (as a JSON string).
    case secondsSince1970
    /// Encode the `Date` as UNIX millisecond timestamp (as a JSON string).
    case millisecondsSince1970
}

extension QueryValue {
    public static func array(_ values: [Float]) -> Self {
        .array(values.map(Self.float))
    }
    public static func array(_ values: [Double]) -> Self {
        .array(values.map(Float.init).map(Self.float))
    }
    public static func array(_ values: [Int]) -> Self {
        .array(values.map(Self.int))
    }
    public static func array(_ values: [String]) -> Self {
        .array(values.map(Self.string))
    }
    public static func array(describing values: [some CustomStringConvertible]) -> Self {
        .array(values.map(\.description).map(Self.string))
    }
    public static func string(describing value: some CustomStringConvertible) -> Self {
        .string(value.description)
    }
}

extension QueryValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: QueryValue...) {
        self = .array(elements)
    }
}

extension QueryValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension QueryValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, QueryValue)...) {
        var dict = QueryDict()
        for (k, v) in elements {
            dict[k] = v
        }
        self = .dict(dict)
    }
}

extension QueryValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Float) {
        self = .float(value)
    }
}

extension QueryValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension QueryValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}
