import UIKit

// https://developer.github.com/v3/activity/starring/#list-stargazers
struct RequestModel: Equatable, Codable {
    let owner: String
    let repo: String
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
    
    let data: [Stargazer] = [
        Stargazer(name: "Chris")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func makeCall(request: RequestModel) {
//        let urlRequest = URLRequest(url: URL(string: ""))
//        let task = URLSession(configuration: .default).dataTask(with: <#T##URLRequest#>)
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
