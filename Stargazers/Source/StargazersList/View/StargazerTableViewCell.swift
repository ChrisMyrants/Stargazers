import UIKit

class StargazerTableViewCell: UITableViewCell {
    static let reusableIdentifier = "StargazerTableViewCell"
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var onReuse: () -> Void = {}
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
        avatarImage.image = nil
    }
}
