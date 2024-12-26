////
////  LevelThreeView.swift
////  Kewan
////
////  Created by Zhongxin qiu on 2024/11/30.
////
//
//import SwiftUI
//
//struct Level3: View {
//    @ObservedObject var gameVM: GameViewModel
//    @Binding var showGameView: Bool
//    @StateObject private var settings = AppSettings.shared
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                // 背景色
//                settings.color.opacity(settings.backgroundOpacity).ignoresSafeArea()
//                
//                // ... rest of the existing code ...
//            }
//        }
//        .onAppear {
//            // 直接使用 ContentView 传入的数据开始游戏
//            print("Level3 开始游戏")
//            setupGame()
//        }
//    }
//}
//
//#Preview {
//    NavigationView {
//        Level3(gameVM: {
//            let vm = GameViewModel()
//            vm.currentWords = LocalDataManager.shared.getRandomFiveWords()
//            return vm
//        }(),
//                     showGameView: .constant(true))
//    }
//}
