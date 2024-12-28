import Foundation

class MenuViewModel {
    var onItemsUpdated: (() -> Void)?
    var menuItems: [MenuItem] = [] {
        didSet {
            onItemsUpdated?()
        }
    }
    
    func fetchMenuItems(for category: String) {
        Task {
            do {
                let items = try await MenuController.shared.fetchMenuItems(for: category)
                self.menuItems = items
            } catch {
                print("Error fetching menu items: \(error)")
            }
        }
    }
}
