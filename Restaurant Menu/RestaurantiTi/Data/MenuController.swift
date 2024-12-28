import Foundation
import UIKit

class MenuController {
    typealias MinutesToPrepare = Int
    let baseURL: URL? = URL(string: "http://localhost:8080/")
    
    var order = Order() {
        didSet {
            NotificationCenter.default.post(name: MenuController.orderUpdatedNotification, object: nil)
        }
    }
    
    static let shared = MenuController()
    static let orderUpdatedNotification = Notification.Name("MenuController.orderUpdated")
    
    func fetchCategories() async throws -> [String] {
        guard let categoriesURL = baseURL?.appendingPathComponent("categories") else {
            throw MenuControllerError.categoriesNotFound
        }
        
        let (data, response) = try await URLSession.shared.data(from: categoriesURL)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MenuControllerError.categoriesNotFound
        }
        
        let jsonDecoder = JSONDecoder()
        let categoriesResponse = try jsonDecoder.decode(CategoriesResponse.self, from: data)
        return categoriesResponse.categories
    }
    
    func fetchMenuItems(for inputCategory: String) async throws -> [MenuItem] {
        guard let baseMenuURL = baseURL?.appendingPathComponent("menu") else {
            throw MenuControllerError.menuItemsNotFound
        }
        var urlComponents = URLComponents(url: baseMenuURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [URLQueryItem(name: "category", value: inputCategory)]
        guard let menuURL = urlComponents?.url else {
            throw MenuControllerError.menuItemsNotFound
        }
        let (data, response) = try await URLSession.shared.data(from: menuURL)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MenuControllerError.menuItemsNotFound
        }
        let jsonDecoder = JSONDecoder()
        let menuResponse = try jsonDecoder.decode(MenuResponse.self, from: data)
        return menuResponse.items
    }
    
    func sumbitOrder(for menuIds: [Int]) async throws -> MinutesToPrepare {
        guard let orderURL = baseURL?.appendingPathComponent("order") else {
            throw MenuControllerError.orderRequestFailed
        }
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let menuIDsDictionary = ["menuIds": menuIds]
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(menuIDsDictionary)
        request.httpBody = jsonData        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MenuControllerError.orderRequestFailed
        }
        let jsonDecoder = JSONDecoder()
        let orderResponse = try jsonDecoder.decode(OrderResponse.self, from: data)
        return orderResponse.preparaionTime
    }
    
    func fetchImage(from url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MenuControllerError.imageDataMissing
        }
        guard let image = UIImage(data: data) else {
            throw MenuControllerError.imageDataMissing
        }
        return image
    }
    
    enum MenuControllerError: Error, LocalizedError {
        case categoriesNotFound
        case menuItemsNotFound
        case orderRequestFailed
        case imageDataMissing
    }
}
