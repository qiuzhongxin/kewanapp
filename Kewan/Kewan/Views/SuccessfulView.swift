//import SwiftUI
//
//struct SuccessfulView: View {
//    @ObservedObject var gameVM: GameViewModel
//    @Environment(\.dismiss) var dismiss
//    @Binding var showGameView: Bool  // 添加这个绑定
//    
//    var body: some View {
//        VStack(spacing: 30) {
//            Text("恭喜完成!")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .foregroundColor(.green)
//            
//            VStack(spacing: 15) {
//                Text("得分: \(gameVM.score)")
//                    .font(.title2)
//                
//                Text("用时: \(String(format: "%.1f", gameVM.gameTime))秒")
//                    .font(.title2)
//            }
//            .padding()
//            .background(
//                RoundedRectangle(cornerRadius: 15)
//                    .fill(Color.white)
//                    .shadow(radius: 5)
//            )
//            
//            Spacer()
//                .frame(height: 30)
//            
//            VStack(spacing: 20) {
//                if gameVM.currentLevel < 3 {
//                    Button(action: {
//                        gameVM.nextLevel()
//                        dismiss()
//                    }) {
//                        HStack {
//                            Text("继续下一关")
//                            Image(systemName: "arrow.right.circle.fill")
//                        }
//                        .font(.title3)
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(width: 200)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                    }
//                }
//                
//                Button(action: {
//                    gameVM.restartLevel()
//                    dismiss()
//                }) {
//                    HStack {
//                        Text("重新开始")
//                        Image(systemName: "arrow.clockwise.circle.fill")
//                    }
//                    .font(.title3)
//                    .foregroundColor(.white)
//                    .padding()
//                    .frame(width: 200)
//                    .background(Color.orange)
//                    .cornerRadius(10)
//                }
//                
//                Button(action: {
//                    gameVM.exitGame()
//                    showGameView = false  // 使用绑定来关闭游戏视图
//                }) {
//                    HStack {
//                        Text("返回主菜单")
//                        Image(systemName: "house.fill")
//                    }
//                    .font(.title3)
//                    .foregroundColor(.white)
//                    .padding()
//                    .frame(width: 200)
//                    .background(Color.red)
//                    .cornerRadius(10)
//                }
//            }
//        }
//        .padding()
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.blue.opacity(0.1))
//    }
//}
//
//struct SuccessfulView_Previews: PreviewProvider {
//    static var previews: some View {
//        SuccessfulView(
//            gameVM: GameViewModel(),
//            showGameView: .constant(true)
//        )
//    }
//}
