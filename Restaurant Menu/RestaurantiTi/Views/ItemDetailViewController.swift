import UIKit

class ItemDetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var addToOrderButton: UIButton!
    
    var menuItem: MenuItem!
    
    init?(coder: NSCoder, menuItem: MenuItem) {
        self.menuItem = menuItem
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let menuItem = menuItem else {
                print("menuItem is nil")
                return
            }
        print("Received menuItem: \(menuItem.name)")
            updateUI()
    }
    
    @IBAction func orderButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1) {
            self.addToOrderButton.transform = CGAffineTransform(scaleX: 2, y: 2)
            self.addToOrderButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        MenuController.shared.order.userSelected.append(menuItem)
    }
    
    func updateUI() {
        guard let menuItem = menuItem else {
            print("menuItem is nil in updateUI")
            return
        }
        nameLabel.text = menuItem.name
        priceLabel.text = menuItem.price.formatted(.currency(code: "usd"))
        detailLabel.text = menuItem.detailText
        
        Task {
            do {
                let fetchedImage = try await MenuController.shared.fetchImage(from: menuItem.imageURL)
                imageView.image = fetchedImage
            } catch {
                print("Failed to fetch image: \(error)")
            }
        }
    }
}
