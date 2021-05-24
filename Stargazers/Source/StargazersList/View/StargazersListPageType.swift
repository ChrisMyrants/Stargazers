protocol StargazersListPageType: AnyObject {
    var delegate: StargazersListDelegate? { get set }
    func update(_ viewState: StargazersListViewState)
}
