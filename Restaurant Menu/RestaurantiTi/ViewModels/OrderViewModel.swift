import Foundation
import UIKit

class OrderViewModel {
    var orderItems: [MenuItem] = []
    var preparationTime: Int = 0
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    var onOrderItemsUpdated: (() -> Void)?
    
    func addMenuItem(_ menuItem: MenuItem) {
            orderItems.append(menuItem)
            onOrderItemsUpdated?()
        }
    
    func removeMenuItem(at index: Int) {
        guard index >= 0 && index < orderItems.count else {
            print("Index out of range")
            return
        }
        orderItems.remove(at: index)
        onOrderItemsUpdated?()
    }
    
    func calculateTotal() -> Double {
        return orderItems.reduce(0) { $0 + $1.price }
    }
    
    func fetchImage(for item: MenuItem, at indexPath: IndexPath, completion: @escaping (UIImage?) -> Void) {
        imageLoadTasks[indexPath] = Task {
            if let fetchedImage = try? await MenuController.shared.fetchImage(from: item.imageURL) {
                completion(fetchedImage)
            } else {
                completion(nil)
            }
            imageLoadTasks[indexPath] = nil
        }
    }
    
    func submitOrder(completion: @escaping (Result<Int, Error>) -> Void) {
        let selectedMenuIDs = orderItems.map { $0.id }
        Task {
            do {
                let minutesToPrepare = try await MenuController.shared.sumbitOrder(for: selectedMenuIDs)
                preparationTime = minutesToPrepare
                clearOrder()
                completion(.success(minutesToPrepare))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func clearOrder() {
        MenuController.shared.order.userSelected.removeAll()
    }

}
