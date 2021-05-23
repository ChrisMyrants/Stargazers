import Foundation

struct RequestModel: Equatable, Encodable {
    let owner: String
    let repo: String
    let page: Int
}

struct ResponseModel: Equatable, Decodable {
    let login: String
    let avatar_url: URL
    
    func to() -> StargazersListViewState.Stargazer {
        StargazersListViewState.Stargazer(name: login, avatarURL: avatar_url)
    }
}
