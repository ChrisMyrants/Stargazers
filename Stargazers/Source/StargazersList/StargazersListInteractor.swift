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
        let requestModel = RequestModel(owner: owner, repo: repo, page: 1)
        networkManager.askStargazersList(requestModel: requestModel) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case let .success(response):
                    self.page?.update(StargazersListViewState(stargazers: response.map { $0.to() }, page: 1, failureMessage: nil))
                case let .failure(.httpError(code: code, message: message)):
                    self.page?.update(StargazersListViewState(stargazers: [], page: 0, failureMessage: "HTTP error code: \(code)\n\(message.get(or: ""))"))
                case .failure(.decodingFailure):
                    self.page?.update(StargazersListViewState(stargazers: [], page: 0, failureMessage: "Failure on response decode"))
                case .failure(.unknown):
                    self.page?.update(StargazersListViewState(stargazers: [], page: 0, failureMessage: "Generic error"))
                }
            }
        }
    }
    
    func askNextPage(owner: String, repo: String, currentViewState: StargazersListViewState) {
        let nextPage = currentViewState.page + 1
        let requestModel = RequestModel(owner: owner, repo: repo, page: nextPage)
        
        networkManager.askStargazersList(requestModel: requestModel) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case let .success(response):
                    self.page?.update(StargazersListViewState(stargazers: currentViewState.stargazers + response.map { $0.to() }, page: nextPage, failureMessage: nil))
                case let .failure(.httpError(code: code, message: message)):
                    self.page?.update(StargazersListViewState(stargazers: currentViewState.stargazers, page: currentViewState.page, failureMessage: "HTTP error code: \(code)\n\(message.get(or: ""))"))
                case .failure(.decodingFailure):
                    self.page?.update(StargazersListViewState(stargazers: currentViewState.stargazers, page: currentViewState.page, failureMessage: "Failure on response decode"))
                case .failure(.unknown):
                    self.page?.update(StargazersListViewState(stargazers: currentViewState.stargazers, page: currentViewState.page, failureMessage: "Generic error"))
                }
            }
        }
    }
}

extension StargazersListInteractor: StargazersListDelegate {
    func newList(owner: String, repo: String) {
        askStargazersList(owner: owner, repo: repo)
    }
    
    func nextPage(owner: String, repo: String, currentViewState: StargazersListViewState) {
        askNextPage(owner: owner, repo: repo, currentViewState: currentViewState)
    }
}
