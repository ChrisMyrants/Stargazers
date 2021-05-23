import Foundation

struct StargazersListViewState {
    let stargazers: [Stargazer]
    let failureMessage: String?
    
    struct Stargazer {
        let name: String
        let avatarURL: URL
    }
}
