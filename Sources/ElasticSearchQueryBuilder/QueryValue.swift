import Foundation

public typealias QueryDict = [ String : QueryValue? ]

public enum QueryValue: Equatable {
    case array([QueryValue])
    case date(Date)
    case dict(QueryDict)
    case float(Float)
    case int(Int)
    case string(String)
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
