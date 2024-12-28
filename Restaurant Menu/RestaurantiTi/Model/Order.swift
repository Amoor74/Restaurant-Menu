import Foundation

struct Order: Codable {
    var userSelected: [MenuItem]
    
    init(userSelected: [MenuItem] = []) {
        self.userSelected = userSelected
    }
}
