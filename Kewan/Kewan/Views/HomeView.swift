//
//  HomeView.swift
//  Kewan
//
//  Created by Zhongxin qiu on 2024/11/30.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var userVM = UserViewModel()
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "gamecontroller")
                    Text("游戏")
                }
            
            ScoreView()
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
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
}
