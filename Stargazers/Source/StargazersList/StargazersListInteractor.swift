import Foundation

class StargazersListInteractor {
    private let networkManager: NetworkManager
    weak var page: StargazersListPage?
    
    init(networkManager: NetworkManager, page: StargazersListPage?) {
        self.networkManager = networkManager
        self.page = page
        self.page?.delegate = self
    }
    
    func askStargazersList(owner: String, repo: String) {
        let requestModel = RequestModel(owner: owner, repo: repo)
        networkManager.askStargazersList(requestModel: requestModel) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case let .success(response):
                    self.page?.update(StargazersListViewState(stargazers: response.map { $0.to() }, failureMessage: nil))
                case let .failure(.httpError(code: code, message: message)):
                    self.page?.update(StargazersListViewState(stargazers: [], failureMessage: "HTTP error code: \(code)\n\(message.get(or: ""))"))
                case .failure(.decodingFailure):
                    self.page?.update(StargazersListViewState(stargazers: [], failureMessage: "Failure on response decode"))
                case .failure(.unknown):
                    self.page?.update(StargazersListViewState(stargazers: [], failureMessage: "Generic error"))
                }
            }
        }
    }
}

extension StargazersListInteractor: StargazersListDelegate {
    func send(owner: String, repo: String) {
        askStargazersList(owner: owner, repo: repo)
    }
}
