import Foundation

class StargazersListInteractor {
    func askStargazersList(owner: String, repo: String, _ completionHandler: @escaping (Result<[ResponseModel],Error>) -> ()) {
        
        // TODO: remove this implementation
        let requestoModel = RequestModel(owner: owner, repo: repo)
        
        let urlRequest = URLRequest(url: URL(string: "https://api.github.com/repos/\(requestoModel.owner)/\(requestoModel.repo)/stargazers")!)
        
        let dataTask =
            URLSession(configuration: .default).dataTask(with: urlRequest) { [weak self] data, response, error in
                print("Complete call with: \n- URL: \(urlRequest)\n- Data: \(data)\n- Response: \(response)\n- Error: \(error)")
                
                DispatchQueue.main.async {
                    if response.flatMap(\.statusCode) == 200 || response.flatMap(\.statusCode) == 201 {
                        guard
                            let data = data,
                            let response = response as? HTTPURLResponse,
                            response.statusCode == 200,
                            let decoded = (try? JSONDecoder().decode([ResponseModel].self, from: data)) else { return }
                        
                        completionHandler(.success(decoded))
                        return
                    } else {
                        completionHandler(.failure("HTTP Status code: \(response.flatMap(\.statusCode).get(or: -1))\nError: \(error)"))
                        return
                    }
                    
                    if let error = error {
                        completionHandler(.failure("HTTP Status code: \(response.flatMap(\.statusCode).get(or: -1))\nError: \(error)"))
                        return
                    } else if
                        let data = data,
                        let response = response as? HTTPURLResponse,
                        response.statusCode == 200,
                        let decoded = (try? JSONDecoder().decode([ResponseModel].self, from: data)) {
                        
                        completionHandler(.success(decoded))
                        return
                    }
                }
            }
        
        dataTask.resume()
    }
}
