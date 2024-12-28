import UIKit

class OrderConfirmationViewController: UIViewController {
    @IBOutlet var confirmationLabel: UILabel!
    typealias MinutesToPrepare = Int
    var preparationTime: MinutesToPrepare
    
    init?(coder: NSCoder, preparationTime: MinutesToPrepare) {
        self.preparationTime = preparationTime
        super.init(coder: coder)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        isModalInPresentation = true
        confirmationLabel.text = "Thank you for your order! Approximately wait time is \(preparationTime) minutes."
    }
 
}
