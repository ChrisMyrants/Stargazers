import Foundation
import UIKit

extension Bool {
    var not: Bool {
        !self
    }
}

extension Optional {
    func get(or value: Wrapped) -> Wrapped {
        guard let wrapped = self else { return value }
        return wrapped
    }
}

extension URLResponse {
    var statusCode: Int? {
        (self as? HTTPURLResponse).map(\.statusCode)
    }
}

extension String: Error {}

extension Result {
    var tryGet: Success? {
        switch self {
        case let .success(value):
            return value
        case .failure:
            return nil
        }
    }
}
