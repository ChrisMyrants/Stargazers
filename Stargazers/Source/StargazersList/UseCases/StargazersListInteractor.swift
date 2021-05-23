import Foundation

class StargazersListInteractor {
    // MARK: Public properties
    weak var page: StargazersListPage?
    
    // MARK: Private properties
    private let networkManager: NetworkManager
    
    // MARK: Public methods
    init(networkManager: NetworkManager, page: StargazersListPage?) {
        self.networkManager = networkManager
        self.page = page
        self.page?.delegate = self
    }
}

// MARK: StargazersListDelegate
extension StargazersListInteractor: StargazersListDelegate {
    func askStargazersList(owner: String, repo: String) {
        let requestModel = RequestModel(owner: owner, repo: repo, page: 1)
        networkManager.askStargazersList(requestModel: requestModel) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(response):
                self.page?.update(StargazersListViewState(
                                    stargazers: response.map { $0.to() },
                                    page: 1,
                                    isLastPage: response.isEmpty,
                                    failureMessage: nil))
                
            case let .failure(.httpError(code: code, message: message)):
                self.page?.update(StargazersListViewState(
                                    stargazers: [],
                                    page: 0,
                                    isLastPage: false,
                                    failureMessage: "HTTP error code: \(code)\n\(message.get(or: ""))"))
                
            case .failure(.decodingFailure):
                self.page?.update(StargazersListViewState(
                                    stargazers: [],
                                    page: 0,
                                    isLastPage: false,
                                    failureMessage: "Failure on response decode"))
                
            case .failure(.unknown):
                self.page?.update(StargazersListViewState(
                                    stargazers: [],
                                    page: 0,
                                    isLastPage: false,
                                    failureMessage: "Generic error"))
            }
        }
    }
    
    func askNextPage(owner: String, repo: String, currentViewState: StargazersListViewState) {
        let nextPage = currentViewState.page + 1
        let requestModel = RequestModel(owner: owner, repo: repo, page: nextPage)
        
        networkManager.askStargazersList(requestModel: requestModel) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(response):
                self.page?.update(StargazersListViewState(
                                    stargazers: currentViewState.stargazers + response.map { $0.to() },
                                    page: nextPage,
                                    isLastPage: response.isEmpty,
                                    failureMessage: nil))
                
            case let .failure(.httpError(code: code, message: message)):
                self.page?.update(StargazersListViewState(
                                    stargazers: currentViewState.stargazers,
                                    page: currentViewState.page,
                                    isLastPage: currentViewState.isLastPage,
                                    failureMessage: "HTTP error code: \(code)\n\(message.get(or: ""))"))
                
            case .failure(.decodingFailure):
                self.page?.update(StargazersListViewState(
                                    stargazers: currentViewState.stargazers,
                                    page: currentViewState.page,
                                    isLastPage: currentViewState.isLastPage,
                                    failureMessage: "Failure on response decode"))
                
            case .failure(.unknown):
                self.page?.update(StargazersListViewState(
                                    stargazers: currentViewState.stargazers,
                                    page: currentViewState.page,
                                    isLastPage: currentViewState.isLastPage,
                                    failureMessage: "Generic error"))
            }
        }
    }
}
