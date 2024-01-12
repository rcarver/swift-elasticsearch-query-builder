import Foundation

public typealias QueryDict = [ String : QueryValue ]

public enum QueryValue: Equatable {
    case array([QueryValue])
    case date(Date, format: QueryDateFormat)
    case dict(QueryDict)
    case float(Float)
    case int(Int)
    case string(String)
}

public enum QueryDateFormat {
    /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
    case iso8601
    /// Encode the `Date` as a UNIX timestamp (as a JSON string).
    case secondsSince1970
    /// Encode the `Date` as UNIX millisecond timestamp (as a JSON string).
    case millisecondsSince1970
}

extension QueryValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: QueryValue...) {
        self = .array(elements)
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
