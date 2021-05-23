import UIKit

class StargazerTableViewCell: UITableViewCell {
    // MARK: Static properties
    static let reusableIdentifier = "StargazerTableViewCell"
    
    // MARK: IBOutlets
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    // MARK: Public Properties
    var onReuse: () -> Void = {}
    
    // MARK: Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
        avatarImage.image = nil
    }
}
