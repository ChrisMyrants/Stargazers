protocol StargazersListNetworkType: AnyObject {
    func askStargazersList(requestModel: RequestModel, _ completionHandler: @escaping (Result<[ResponseModel],ClientError>) -> ())
}
