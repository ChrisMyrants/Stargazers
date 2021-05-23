protocol StargazersListDelegate: AnyObject {
    func askStargazersList(owner: String, repo: String)
    func askNextPage(owner: String, repo: String, currentViewState: StargazersListViewState)
}
