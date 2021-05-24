import Foundation

struct RequestModel: Equatable, Encodable {
    let owner: String
    let repo: String
    let page: Int
}

struct ResponseModel: Equatable, Decodable {
    let login: String
    let avatarURL: URL
    
    private enum CodingKeys: String, CodingKey {
        case login
        case avatarURL = "avatar_url"
    }
    
    func to() -> StargazersListViewState.Stargazer {
        StargazersListViewState.Stargazer(name: login, avatarURL: avatarURL)
    }
}
