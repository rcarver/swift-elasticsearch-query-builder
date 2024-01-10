import Foundation

extension QueryValue: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .array(value):
            try container.encode(value)
        case let .date(value):
            try container.encode(value)
        case let .dict(value):
            try container.encode(value)
        case let .float(value):
            try container.encode(value)
        case let .int(value):
            try container.encode(value)
        case let .string(value):
            try container.encode(value)
        }
    }
}
