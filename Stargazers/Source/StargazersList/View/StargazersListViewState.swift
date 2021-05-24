import Foundation

struct StargazersListViewState: Equatable {
    let stargazers: [Stargazer]
    let page: Int
    let isLastPage: Bool
    let failureMessage: String?
    
    struct Stargazer: Equatable {
        let name: String
        let avatarURL: URL
    }
    
    static var starting: StargazersListViewState {
        StargazersListViewState(stargazers: [], page: 0, isLastPage: false, failureMessage: nil)
    }
}
