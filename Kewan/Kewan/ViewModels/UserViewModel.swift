//
//  UserViewModel.swift
//  Kewan
//
//  Created by Zhongxin qiu on 2024/12/9.
//

import SwiftUI
import AuthenticationServices

class UserViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var username: String = ""
    @Published var userAvatar: String = "person.circle.fill"
    @Published var userId: String = ""
    
    init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        self.username = UserDefaults.standard.string(forKey: "username") ?? ""
        self.userId = UserDefaults.standard.string(forKey: "userId") ?? ""
    }
    
    func login(username: String) {
        self.username = username
        self.userId = UUID().uuidString
        self.isLoggedIn = true
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(userId, forKey: "userId")
    }
    
    func loginWithApple(userId: String, username: String?) {
        self.userId = userId
        self.username = username ?? "Apple User"
        self.isLoggedIn = true
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set(self.username, forKey: "username")
        UserDefaults.standard.set(userId, forKey: "userId")
    }
    
    func logout() {
        self.username = ""
        self.userId = ""
        self.isLoggedIn = false
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "userId")
    }
}
