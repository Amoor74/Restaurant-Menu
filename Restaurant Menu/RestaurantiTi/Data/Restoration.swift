import Foundation

extension NSUserActivity {
    var order: Order? {
        get {
            guard let jsonData = userInfo?["order"] as? Data else {return nil}
            return try? JSONDecoder().decode(Order.self, from: jsonData)
        }
        set {
            if let newValue = newValue, let jsonData = try? JSONEncoder().encode(newValue) {
                addUserInfoEntries(from: ["order" : jsonData])
            } else {
                userInfo?["order"] = nil
            }
        }
    }
        
    var controllerIdentifier: StateRestorationController.Identifier? {
        get {
            guard let controllerIdentifierString = userInfo?["controllerIdentifier"] as? String else {return nil}
            return StateRestorationController.Identifier(rawValue: controllerIdentifierString)
        }
        set {
            userInfo?["controllerIdentifier"] = newValue?.rawValue
        }
    }
    
    var menuCategory: String? {
        get {
            return userInfo?["menuCategory"] as? String
        }
        set {
            userInfo?["menuCategory"] = newValue
        }
    }
    
    var menuItem: MenuItem? {
        get {
            guard let jsonData = userInfo?["menuItem"] as? Data else {return nil}
            return try? JSONDecoder().decode(MenuItem.self, from: jsonData)
        }
        set {
            if let newValue = newValue, let jsondata = try? JSONEncoder().encode(newValue) {
                addUserInfoEntries(from: ["menuItem" : jsondata])
            } else {
                userInfo?["menuItem"] = nil
            }
        }
    }
    
}
    
enum StateRestorationController {
    
    enum Identifier : String {
        case categories, menu, itemDetail, order
    }
    
    case categories
    case menu(category: String)
    case itemDetail(MenuItem)
    case order
    
    var identifier: Identifier {
        switch self {
        case .categories: return Identifier.categories
        case .menu: return Identifier.menu
        case .itemDetail: return Identifier.itemDetail
        case .order: return Identifier.order
        }
    }
    
    init?(userActivity: NSUserActivity) {
        guard let identifier = userActivity.controllerIdentifier else {return nil}
        
        switch identifier {
        case .categories:
            self = .categories
            
        case .menu:
            if let activeCategory = userActivity.menuCategory { self = .menu(category: activeCategory) }
            else {return nil}
            
        case .itemDetail:
            if let shownMenuItem = userActivity.menuItem { self = .itemDetail(shownMenuItem) }
            else {return nil}
            
        case .order:
            self = .order
        }
    }
    
}


