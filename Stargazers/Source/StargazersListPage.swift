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

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
        }
    }
    
    var data: [Stargazer] = [
        Stargazer(name: "Chris")
    ] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeCall(request: RequestModel(
                    owner: "ReactiveX",
                    repo: "RxSwift"))
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
