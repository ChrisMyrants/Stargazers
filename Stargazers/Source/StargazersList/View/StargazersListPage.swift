import UIKit

class StargazersListPage: UIViewController {
    // MARK: IBOutlets
    @IBOutlet weak var userTextField: UITextField! {
        didSet {
            userTextField.delegate = self
            userTextField.placeholder = "Username"
        }
    }
    @IBOutlet weak var repositoryTextField: UITextField! {
        didSet {
            repositoryTextField.delegate = self
            repositoryTextField.placeholder = "Repository"
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            
            tableView.register(
                UINib(nibName: "\(StargazerTableViewCell.self)", bundle: nil),
                forCellReuseIdentifier: StargazerTableViewCell.reusableIdentifier)
        }
    }
    
    // MARK: Public properties
    weak var delegate: StargazersListDelegate?
    
    // MARK: Private properties
    private let loader = ImageLoader()

    private var isLoading: Bool = false
    
    private var currentViewState: StargazersListViewState = .starting {
        didSet {
            tableView.reloadData()
            tableView.tableFooterView = nil
            isLoading = false
        }
    }
    
    // MARK: Private methods
    func makeSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        
        footerView.addSubview(spinner)
        spinner.center = footerView.center
        spinner.startAnimating()
        
        return footerView
    }
}

// MARK: StargazersListPageType
extension StargazersListPage: StargazersListPageType {
    func update(_ viewState: StargazersListViewState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.currentViewState = viewState
            
            if let failureMessage = viewState.failureMessage {
                let alertController = UIAlertController(title: "Error", message: failureMessage, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .cancel))
                self.present(alertController, animated: true)
            }
        }
    }
}

// MARK: UITableViewDataSource
extension StargazersListPage: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentViewState.stargazers.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StargazerTableViewCell.reusableIdentifier, for: indexPath) as? StargazerTableViewCell else {
            fatalError("")
        }
        
        cell.usernameLabel.text = currentViewState.stargazers[indexPath.row].name
        let uuid = loader.loadImage(currentViewState.stargazers[indexPath.row].avatarURL) { result in
            DispatchQueue.main.async {
                cell.avatarImage.image = result.tryGet
            }
        }
        cell.onReuse = {
            if let uuid = uuid {
                self.loader.cancelLoad(uuid)
            }
        }
        
        return cell
    }
}

// MARK: UITableViewDelegate
extension StargazersListPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        56
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard
            isLoading.not,
            currentViewState.isLastPage.not,
            let username = userTextField.text,
            let repository = repositoryTextField.text else { return }
        
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height - scrollView.frame.height - 100) {
            delegate?.askNextPage(owner: username, repo: repository, currentViewState: currentViewState)
            tableView.tableFooterView = makeSpinnerFooter()
            isLoading = true
        }
    }
}

// MARK: UITextFieldDelegate
extension StargazersListPage: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let username = userTextField.text,
              let repository = repositoryTextField.text,
              username.isEmpty.not,
              repository.isEmpty.not else { return }
        
        delegate?.askStargazersList(owner: username, repo: repository)
    }
}
