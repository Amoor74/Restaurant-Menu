import Foundation

struct MenuResponse: Codable {
    let items: [MenuItem]
}

struct CategoriesResponse: Codable {
    let categories: [String]
}

struct OrderResponse: Codable {
    let preparaionTime: Int
    
    enum CodingKeys: String, CodingKey {
        case preparaionTime = "preparation_time"
    }
}
