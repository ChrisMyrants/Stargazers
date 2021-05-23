enum ClientError: Error {
    case httpError(code: Int, message: String?)
    case decodingFailure
    case unknown
}
