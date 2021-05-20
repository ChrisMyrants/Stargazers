import UIKit

struct RequestModel: Equatable, Encodable {
    let owner: String
    let repo: String
}

struct ResponseModel: Equatable, Decodable {
    let login: String
    let avatar_url: String
    
    func to() -> Stargazer {
        Stargazer(name: login)
    }
}

struct Stargazer {
    let name: String
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
        }
    }
    
    var data: [Stargazer] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func makeCall(request: RequestModel) {
        let urlRequest = URLRequest(url: URL(string: "https://api.github.com/repos/\(request.owner)/\(request.repo)/stargazers")!)
        
        let dataTask =
            URLSession(configuration: .default).dataTask(with: urlRequest) { [weak self] data, response, error in
                print("Complete call with: \n- URL: \(urlRequest)\n- Data: \(data)\n- Response: \(response)\n- Error: \(error)")
                
                DispatchQueue.main.async {
                    if let error = error {
                        print("On failure with error: \(error)")
                    } else if
                        let data = data,
                        let response = response as? HTTPURLResponse,
                        response.statusCode == 200,
                        let decoded = (try? JSONDecoder().decode([ResponseModel].self, from: data)) {
                        print("On success with response: \(decoded)")
                        self?.data = decoded.map { $0.to() }
                    }
                }
            }
        
        dataTask.resume()
    }
}

extension StargazersListPage: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = data[indexPath.row].name
        
        return cell
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
        
        makeCall(request: RequestModel(owner: username, repo: repository))
    }
}
