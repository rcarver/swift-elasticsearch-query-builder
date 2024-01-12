import Foundation

extension QueryValue: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .array(value):
            try container.encode(value)
        case let .date(value, format: format):
            switch format {
            case .secondsSince1970:
                try container.encode(String(describing: Int(value.timeIntervalSince1970)))
            case .millisecondsSince1970:
                try container.encode(String(describing: Int(value.timeIntervalSince1970 * 1000)))
            }
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
