import Foundation

enum ClientError: Error {
    case httpError(code: Int, message: String?)
    case decodingFailure
    case unknown
}

class NetworkManager {
    func askStargazersList(requestModel: RequestModel, _ completionHandler: @escaping (Result<[ResponseModel],ClientError>) -> ()) {
        let urlRequest = URLRequest(url: URL(string: "https://api.github.com/repos/\(requestModel.owner)/\(requestModel.repo)/stargazers")!)
        
        let dataTask =
            URLSession(configuration: .default).dataTask(with: urlRequest) { optData, optResponse, optError in
                let statusCode = optResponse.flatMap(\.statusCode).get(or: -1)
                
                print("- Data: \(optData.map(\.description).get(or: "no data"))\n- Response: \(optResponse.map(\.description).get(or: "no response"))\n- Error: \(optError.get(or: "no error"))")
                
                switch (optData, optError, statusCode) {
                
                case let (.some(data), nil, 200...201):
                    guard let decoded = (try? JSONDecoder().decode([ResponseModel].self, from: data)) else {
                        completionHandler(.failure(.decodingFailure))
                        return
                    }
                    completionHandler(.success(decoded))
                
                case (_, _, -1):
                    completionHandler(.failure(.unknown))
                
                case let (nil, error, httpCode):
                    completionHandler(.failure(.httpError(code: httpCode, message: error?.localizedDescription)))
                
                case let (_, _, code):
                    completionHandler(.failure(.httpError(code: code, message: nil)))
                }
            }
        
        dataTask.resume()
    }
}
