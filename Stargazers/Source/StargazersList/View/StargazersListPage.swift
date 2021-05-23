import UIKit

protocol StargazersListDelegate: AnyObject {
    func send(owner: String, repo: String)
}

class StargazersListPage: UIViewController {
    
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
    
    weak var delegate: StargazersListDelegate?
    
    let loader = ImageLoader()
    
    var data: [StargazersListViewState.Stargazer] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func update(_ viewState: StargazersListViewState) {
        data = viewState.stargazers
        
        if let failureMessage = viewState.failureMessage {
            let alertController = UIAlertController(title: "Error", message: failureMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(alertController, animated: true)
        }
    }
}

extension StargazersListPage: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StargazerTableViewCell.reusableIdentifier, for: indexPath) as? StargazerTableViewCell else {
            fatalError("")
        }
        
        cell.usernameLabel.text = data[indexPath.row].name
        let uuid = loader.loadImage(data[indexPath.row].avatarURL) { result in
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

extension StargazersListPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        56
    }
}

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
        
        delegate?.send(owner: username, repo: repository)
//        makeCall(request: RequestModel(owner: username, repo: repository))
    }
}
