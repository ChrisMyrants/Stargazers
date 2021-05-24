import XCTest
@testable import Stargazers

fileprivate class MockPage: StargazersListPageType {
    var delegate: StargazersListDelegate?
    var updates: [StargazersListViewState] = []
    
    func update(_ viewState: StargazersListViewState) {
        updates.append(viewState)
    }
}

fileprivate class MockNetwork: StargazersListNetworkType {
    var forcedResult: Result<[ResponseModel], ClientError>
    
    init(forcedResult: Result<[ResponseModel], ClientError>) {
        self.forcedResult = forcedResult
    }
    
    func askStargazersList(requestModel: RequestModel, _ completionHandler: @escaping (Result<[ResponseModel], ClientError>) -> ()) {
        completionHandler(forcedResult)
    }
}

final class StargazersListInteractorTests: XCTestCase {
    fileprivate var sut: StargazersListInteractor?
    fileprivate var network: MockNetwork?
    fileprivate var page: MockPage?
    
    override func tearDown() {
        sut = nil
        network = nil
        page = nil
        
        super.tearDown()
    }
    
    // MARK: AskStargazersList Tests
    func testAskStargazersList_NetworkReturnSuccessfulResult_PageUpdatesWithReceivedSuccessfulResponse() {
        
        /// GIVEN: network response is successful
        let responseModel: [ResponseModel] = [
            .init(login: "name_1", avatar_url: URL(string: "https://www.nba.com")!)
        ]
        let expectedViewState = StargazersListViewState(
            stargazers: responseModel.map { $0.to() },
            page: 1,
            isLastPage: false,
            failureMessage: nil)
        
        page = MockPage()
        network = MockNetwork(forcedResult: .success(responseModel))
        sut = StargazersListInteractor(networkManager: network!, page: page!)
        /// --------------------------------
        
        /// WHEN: .askStargazersList is called
        sut?.askStargazersList(owner: "any", repo: "any")
        /// --------------------------------
        
        /// THEN: one successful expected view state will be sent to page
        XCTAssertEqual(page!.updates, [expectedViewState])
        /// --------------------------------
    }
    
    func testAskStargazersList_NetworkReturnSuccessfulEmptyResult_PageUpdatesWithReceivedSuccessfulEmptyResponse() {
        
        /// GIVEN: network response is successful but empty
        let responseModel: [ResponseModel] = []
        let expectedViewState = StargazersListViewState(
            stargazers: [],
            page: 1,
            isLastPage: true,
            failureMessage: nil)
        
        page = MockPage()
        network = MockNetwork(forcedResult: .success(responseModel))
        sut = StargazersListInteractor(networkManager: network!, page: page!)
        /// --------------------------------
        
        /// WHEN: .askStargazersList is called
        sut?.askStargazersList(owner: "any", repo: "any")
        /// --------------------------------
        
        /// THEN: one empty successful expected view state will be sent to page
        XCTAssertEqual(page!.updates, [expectedViewState])
        /// --------------------------------
    }
    
    func testAskStargazersList_NetworkReturnFailureResult_PageUpdatesWithReceivedFailureResponse() {
        
        /// GIVEN: network response is successful
        let expectedError: ClientError = .httpError(code: 404, message: "404 error")
        let expectedViewState = StargazersListViewState(
            stargazers: [],
            page: 0,
            isLastPage: false,
            failureMessage: expectedError.description)
        
        page = MockPage()
        network = MockNetwork(forcedResult: .failure(expectedError))
        sut = StargazersListInteractor(networkManager: network!, page: page!)
        /// --------------------------------
        
        /// WHEN: .askStargazersList is called
        sut?.askStargazersList(owner: "any", repo: "any")
        /// --------------------------------
        
        /// THEN: one successful expected view state will be sent to page
        XCTAssertEqual(page!.updates, [expectedViewState])
        /// --------------------------------
    }
    
    // MARK: AskNextPage Tests
    func testAskNextPage_NetworkReturnSuccessfulResult_PageUpdatesWithReceivedSuccessfulResponse() {
        
        /// GIVEN: network response is successful
        let currentViewState = StargazersListViewState(
            stargazers: [
                .init(name: "name_0", avatarURL: URL(string: "https://www.nfl.com")!)
            ],
            page: 1,
            isLastPage: false,
            failureMessage: nil)
        let responseModel: [ResponseModel] = [
            .init(login: "name_1", avatar_url: URL(string: "https://www.nba.com")!)
        ]
        let expectedViewState = StargazersListViewState(
            stargazers: currentViewState.stargazers + responseModel.map { $0.to() },
            page: 2,
            isLastPage: false,
            failureMessage: nil)
        
        page = MockPage()
        network = MockNetwork(forcedResult: .success(responseModel))
        sut = StargazersListInteractor(networkManager: network!, page: page!)
        /// --------------------------------
        
        /// WHEN: .askStargazersList is called
        sut?.askNextPage(owner: "any", repo: "any", currentViewState: currentViewState)
        /// --------------------------------
        
        /// THEN: one successful expected view state will be sent to page
        XCTAssertEqual(page!.updates, [expectedViewState])
        /// --------------------------------
    }
    
    func testAskNextPage_NetworkReturnSuccessfulEmptyResult_PageUpdatesWithReceivedSuccessfulEmptyResponse() {
        
        /// GIVEN: network response is successful but empty
        let currentViewState = StargazersListViewState(
            stargazers: [
                .init(name: "name_0", avatarURL: URL(string: "https://www.nfl.com")!)
            ],
            page: 1,
            isLastPage: false,
            failureMessage: nil)
        
        let expectedViewState = StargazersListViewState(
            stargazers: currentViewState.stargazers,
            page: 1,
            isLastPage: true,
            failureMessage: nil)
        
        page = MockPage()
        network = MockNetwork(forcedResult: .success([]))
        sut = StargazersListInteractor(networkManager: network!, page: page!)
        /// --------------------------------
        
        /// WHEN: .askStargazersList is called
        sut?.askNextPage(owner: "any", repo: "any", currentViewState: currentViewState)
        /// --------------------------------
        
        /// THEN: one empty successful expected view state will be sent to page
        XCTAssertEqual(page!.updates, [expectedViewState])
        /// --------------------------------
    }
    
    func testAskNextPage_NetworkReturnFailureResult_PageUpdatesWithReceivedFailureResponse() {
        
        /// GIVEN: network response is failure
        let currentViewState = StargazersListViewState(
            stargazers: [
                .init(name: "name_0", avatarURL: URL(string: "https://www.nfl.com")!)
            ],
            page: 1,
            isLastPage: false,
            failureMessage: nil)
        let clientError: ClientError = .decodingFailure
        
        let expectedViewState = StargazersListViewState(
            stargazers: currentViewState.stargazers,
            page: 1,
            isLastPage: false,
            failureMessage: clientError.description)
        
        page = MockPage()
        network = MockNetwork(forcedResult: .failure(clientError))
        sut = StargazersListInteractor(networkManager: network!, page: page!)
        /// --------------------------------
        
        /// WHEN: .askStargazersList is called
        sut?.askNextPage(owner: "any", repo: "any", currentViewState: currentViewState)
        /// --------------------------------
        
        /// THEN: one failure expected view state will be sent to page
        XCTAssertEqual(page!.updates, [expectedViewState])
        /// --------------------------------
    }
}
