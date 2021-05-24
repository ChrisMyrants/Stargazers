import UIKit

class ImageLoader {
    // MARK: Private properties
    private var loadedImages: [URL:UIImage] = [:]
    private var runningRequests: [UUID:URLSessionDataTask] = [:]
    
    // MARK: Public methods
    func loadImage(_ url: URL, _ completion: @escaping (Result<UIImage, ClientError>) -> Void) -> UUID? {
        
        if let image = loadedImages[url] {
            completion(.success(image))
            return nil
        }
        
        let uuid = UUID()
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            defer {
                self.runningRequests.removeValue(forKey: uuid)
            }
            
            if let data = data, let image = UIImage(data: data) {
                self.loadedImages[url] = image
                completion(.success(image))
                return
            }
            
            guard let error = error else {
                completion(.failure(.unknown))
                return
            }
            
            guard (error as NSError).code == NSURLErrorCancelled else {
                let clientError = response
                    .flatMap(\.statusCode)
                    .map { ClientError.httpError(code: $0, message: error.localizedDescription) }
                    .get(or: .unknown)
                
                completion(.failure(clientError))
                return
            }
        }
        
        task.resume()
        
        runningRequests[uuid] = task
        return uuid
    }
    
    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
}
