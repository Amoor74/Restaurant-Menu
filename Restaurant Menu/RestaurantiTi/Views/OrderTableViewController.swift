import UIKit

class OrderTableViewController: UITableViewController {
    @IBOutlet var submitButton: UIBarButtonItem!
    
    var preparationTime = 0
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    var viewModel = OrderViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        updateButtonsOfOrderlist()
        NotificationCenter.default.addObserver(tableView!, selector: #selector(UITableView.reloadData), name: MenuController.orderUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(forName: MenuController.orderUpdatedNotification, object: nil, queue: .main) { notification in self.updateButtonsOfOrderlist()
        }
        
    }
    
    func uploadOrder() {
        let selectedMenuIDs = MenuController.shared.order.userSelected.map { menuItem in
            menuItem.id
        }
        Task {
            do {
                let minutesToPrepare = try await MenuController.shared.sumbitOrder(for: selectedMenuIDs)
                preparationTime = minutesToPrepare
                performSegue(withIdentifier: "confirmOrder", sender: nil)
                
            } catch {
                displayError(error, with: "Order Submission Failed")
                print(error.localizedDescription)
            }
        }
    }
    
    func displayError(_ error: Error, with title: String) {
        guard let _ = viewIfLoaded?.window else { return }
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func updateButtonsOfOrderlist() {
        if MenuController.shared.order.userSelected.isEmpty {
            navigationItem.leftBarButtonItem?.isEnabled = false
            submitButton.isEnabled = false
        } else {
            navigationItem.leftBarButtonItem?.isEnabled = true
            submitButton.isEnabled = true
        }
    }
    
    func configure(_ cell: UITableViewCell, forItemAt indexpath: IndexPath) {
        guard let cell = cell as? MenuItemCell else { return }
        let itemToShow = MenuController.shared.order.userSelected[indexpath.row]
        cell.itemName = itemToShow.name
        cell.price = itemToShow.price
        cell.image = nil
        
        imageLoadTasks[indexpath] = Task {
            if let fetchedImage = try? await MenuController.shared.fetchImage(from: itemToShow.imageURL) {
                if let currentIndexpath = tableView.indexPath(for: cell), currentIndexpath == indexpath {
                    cell.image = fetchedImage
                }
            }
            imageLoadTasks[indexpath] = nil
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        MenuController.shared.order.userSelected.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Order", for: indexPath)
        configure(cell, forItemAt: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            MenuController.shared.order.userSelected.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBSegueAction func confirmOrder(_ coder: NSCoder, sender: Any?) -> OrderConfirmationViewController? {
        return OrderConfirmationViewController(coder: coder, preparationTime: viewModel.preparationTime)
    }
    
    @IBAction func unwindToOrderList(segue: UIStoryboardSegue) {
        if segue.identifier == "dismissConfirmation" {
            viewModel.clearOrder()
        }
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        let orderTotal = viewModel.calculateTotal()
            let formattedTotal = orderTotal.formatted(.currency(code: "usd"))
            let alert = UIAlertController(title: "Confirm Order", message: "You are about to submit your order with a total of \(formattedTotal)", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
                self.viewModel.submitOrder { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_):
                            self.viewModel.clearOrder()
                            self.tableView.reloadData()
                            self.performSegue(withIdentifier: "confirmOrder", sender: nil)
                        case .failure(let error):
                            self.displayError(error, with: "Order Submission Failed")
                        }
                    }
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            present(alert, animated: true)
    }
    
}
