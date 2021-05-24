import Foundation

class StargazersListInteractor {
    // MARK: Private properties
    private weak var networkManager: StargazersListNetworkType?
    private weak var page: StargazersListPageType?
    
    // MARK: Public methods
    init(networkManager: StargazersListNetworkType, page: StargazersListPageType) {
        self.networkManager = networkManager
        self.page = page
        self.page?.delegate = self
    }
}

// MARK: StargazersListDelegate
extension StargazersListInteractor: StargazersListDelegate {
    func askStargazersList(owner: String, repo: String) {
        let requestModel = RequestModel(owner: owner, repo: repo, page: 1)
        networkManager?.askStargazersList(requestModel: requestModel) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(response):
                self.page?.update(StargazersListViewState(
                                    stargazers: response.map { $0.to() },
                                    page: 1,
                                    isLastPage: response.isEmpty,
                                    failureMessage: nil))
            
            case let .failure(error):
                self.page?.update(StargazersListViewState(
                                    stargazers: [],
                                    page: 0,
                                    isLastPage: false,
                                    failureMessage: error.description))
            }
        }
    }
    
    func askNextPage(owner: String, repo: String, currentViewState: StargazersListViewState) {
        let nextPage = currentViewState.page + 1
        let requestModel = RequestModel(owner: owner, repo: repo, page: nextPage)
        
        networkManager?.askStargazersList(requestModel: requestModel) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(response):
                self.page?.update(StargazersListViewState(
                                    stargazers: currentViewState.stargazers + response.map { $0.to() },
                                    page: response.isEmpty ? currentViewState.page : nextPage,
                                    isLastPage: response.isEmpty,
                                    failureMessage: nil))
            
            case let .failure(error):
                self.page?.update(StargazersListViewState(
                                    stargazers: currentViewState.stargazers,
                                    page: currentViewState.page,
                                    isLastPage: currentViewState.isLastPage,
                                    failureMessage: error.description))
            }
        }
    }
}
