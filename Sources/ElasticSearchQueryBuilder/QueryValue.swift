import Foundation

typealias QueryDict = [ String : QueryValue? ]

enum QueryValue: Equatable {
    case array([QueryValue])
    case date(Date)
    case dict(QueryDict)
    case float(Float)
    case int(Int)
    case string(String)
}

extension QueryValue: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: QueryValue...) {
        self = .array(elements)
    }
}

extension QueryValue: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: (String, QueryValue)...) {
        var dict = QueryDict()
        for (k, v) in elements {
            dict[k] = v
        }
        self = .dict(dict)
    }
}

extension QueryValue: ExpressibleByFloatLiteral {
    init(floatLiteral value: Float) {
        self = .float(value)
    }
}

extension QueryValue: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension QueryValue: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self = .string(value)
    }
}
