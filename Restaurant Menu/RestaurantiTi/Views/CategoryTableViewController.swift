import UIKit

class CategoryTableViewController: UITableViewController {
    var categories = [String]()
    var viewModel = MenuViewModel()

    override func viewDidLoad() {
            super.viewDidLoad()
            viewModel.onItemsUpdated = { [weak self] in
                self?.updateUI()
            }
            fetchCategories()
        }
    
    func fetchCategories() {
            Task {
                do {
                    categories = try await MenuController.shared.fetchCategories()
                    updateUI()
                } catch {
                    print("Error fetching categories: \(error)")
                }
            }
        }

        func updateUI() {
            tableView.reloadData()
        }
    
    func displayError(_ this: Error, title: String) {
        guard let _ = viewIfLoaded?.window else { return }
        let alert = UIAlertController(title: title, message: this.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBSegueAction func showMenu(_ coder: NSCoder, sender: Any?) -> MenuTableViewController? {
        guard let cell = sender as? UITableViewCell, let indexpath = tableView.indexPath(for: cell) else { return nil }
        let category = categories[indexpath.row]
        return MenuTableViewController(coder: coder, category: category)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Category", for: indexPath)
        
        let item = categories[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = item.capitalized
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
   
}
