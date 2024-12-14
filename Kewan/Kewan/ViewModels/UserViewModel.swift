import SwiftUI

class UserViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var username: String = ""
    
    init() {
        // 从 UserDefaults 读取保存的登录状态
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        self.username = UserDefaults.standard.string(forKey: "username") ?? ""
    }
    
    // 简单登录
    func login(username: String) {
        self.username = username
        self.isLoggedIn = true
        
        // 保存登录状态
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set(username, forKey: "username")
    }
    
    // 登出
    func logout() {
        self.username = ""
        self.isLoggedIn = false
        
        // 清除登录状态
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "username")
    }
}
