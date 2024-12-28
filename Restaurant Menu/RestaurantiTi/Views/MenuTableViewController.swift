import UIKit

class MenuTableViewController: UITableViewController {
    let category: String
    var menuItems = [MenuItem]()
    let viewModel = MenuViewModel()
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    
    init?(coder: NSCoder, category: String) {
        self.category = category
        super.init(coder: coder)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onItemsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        viewModel.fetchMenuItems(for: category)
    }
    
    func updateUI(with newdata: [MenuItem]) {
        menuItems = newdata
        tableView.reloadData()
    }
    
    func displayError(_ error: Error, with title: String) {
        guard let _ = viewIfLoaded?.window else { return }
        
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func configure(_ cell: UITableViewCell, forItemAt indexpath: IndexPath) {
        guard let cell = cell as? MenuItemCell, menuItems.count > 0 else { return }
        let item = menuItems[indexpath.row]
        cell.itemName = item.name
        cell.price = item.price
        cell.image = nil
        
        imageLoadTasks[indexpath] = Task {
            if let fetchedImage = try? await MenuController.shared.fetchImage(from: item.imageURL) {
                if let currentIndexPath = self.tableView.indexPath(for: cell), currentIndexPath == indexpath {
                    cell.image = fetchedImage
                }
            }
            imageLoadTasks[indexpath] = nil
        }
    }
    
    @IBSegueAction func showItemDetail(_ coder: NSCoder, sender: Any?) -> ItemDetailViewController? {
        guard let cell = sender as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return nil }
        guard indexPath.row < viewModel.menuItems.count else {
            print("Index out of range for menuItems")
            return nil
        }
        let tappedElement = viewModel.menuItems[indexPath.row]
        return ItemDetailViewController(coder: coder, menuItem: tappedElement)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItem", for: indexPath)
//        let item = viewModel.menuItems[indexPath.row]
//        cell.textLabel?.text = item.name
//        cell.detailTextLabel?.text = "\(item.price) $"
        configure(cell, forItemAt: indexPath)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = viewModel.menuItems[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        imageLoadTasks[indexPath]?.cancel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(true)
        imageLoadTasks.forEach { key, value in
            value.cancel()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}
