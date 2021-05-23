import Foundation

struct StargazersListViewState {
    let stargazers: [Stargazer]
    let page: Int
    let failureMessage: String?
    
    struct Stargazer: Equatable {
        let name: String
        let avatarURL: URL
    }
    
    static var starting: StargazersListViewState {
        StargazersListViewState(stargazers: [], page: 0, failureMessage: nil)
    }
}
