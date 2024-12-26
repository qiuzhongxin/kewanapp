//
//  HomeView.swift
//  Kewan
//
//  Created by Zhongxin qiu on 2024/11/30.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var userVM = UserViewModel()
    @StateObject private var gameVM = GameViewModel()
    
    var body: some View {
        TabView {
            ContentView(gameVM: gameVM)
                .tabItem {
                    Image(systemName: "gamecontroller")
                    Text("游戏")
                }
                .onChange(of: userVM.userId) { oldValue, newValue in
                    gameVM.setUserId(newValue)
                }
            
            ScoreView(userVM: userVM)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("记录")
                }
            
            SettingsView(userVM: userVM)
                .tabItem {
                    Image(systemName: "gear")
                    Text("设置")
                }
        }
        .onAppear {
            // 初始化时设置用户ID
            gameVM.setUserId(userVM.userId)
        }
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
}
