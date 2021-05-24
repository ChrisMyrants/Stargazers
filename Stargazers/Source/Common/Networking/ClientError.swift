enum ClientError: Error {
    case httpError(code: Int, message: String?)
    case decodingFailure
    case unknown
}

extension ClientError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .httpError(code: code, message: message):
            return "HTTP error code: \(code)\n\(message.get(or: ""))"
        case .decodingFailure:
            return "Failure on response decode"
        case .unknown:
            return "Generic error"
        }
    }
}
