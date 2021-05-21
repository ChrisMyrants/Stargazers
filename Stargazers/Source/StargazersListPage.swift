import UIKit

struct RequestModel: Equatable, Encodable {
    let owner: String
    let repo: String
}

struct ResponseModel: Equatable, Decodable {
    let login: String
    let avatar_url: URL
    
    func to() -> Stargazer {
        Stargazer(name: login, avatarURL: avatar_url)
    }
}

struct Stargazer {
    let name: String
    let avatarURL: URL
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
    
    let loader = ImageLoader()
    
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
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    if response.flatMap(\.statusCode) == 200 || response.flatMap(\.statusCode) == 201 {
                        guard
                            let data = data,
                            let response = response as? HTTPURLResponse,
                            response.statusCode == 200,
                            let decoded = (try? JSONDecoder().decode([ResponseModel].self, from: data)) else { return }
                        
                        print("On success with response: \(decoded)")
                        self.data = decoded.map { $0.to() }
                    } else {
                        let alert = UIAlertController(
                            title: "Errore",
                            message: "HTTP Status code: \(response.flatMap(\.statusCode).get(or: -1))\nError: \(error)",
                            preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                        self.present(alert,
                                     animated: true,
                                     completion: nil)
                    }
                    
                    if let error = error {
                        print("On failure with error: \(error)")
                        self.present(UIAlertController(
                                        title: "Errore",
                                        message: "\(error)",
                                        preferredStyle: .alert),
                                     animated: true,
                                     completion: nil)
                    } else if
                        let data = data,
                        let response = response as? HTTPURLResponse,
                        response.statusCode == 200,
                        let decoded = (try? JSONDecoder().decode([ResponseModel].self, from: data)) {
                        print("On success with response: \(decoded)")
                        self.data = decoded.map { $0.to() }
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
        
        makeCall(request: RequestModel(owner: username, repo: repository))
    }
}
