import SwiftUI

struct SettingsView: View {
    @ObservedObject var userVM: UserViewModel
    @State private var showLoginSheet = false
    
    var body: some View {
        NavigationView {
            List {
                // 用户信息区域
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                        
                        if userVM.isLoggedIn {
                            VStack(alignment: .leading) {
                                Text(userVM.username)
                                    .font(.headline)
                                Text("已登录")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        } else {
                            Button("点击登录") {
                                showLoginSheet = true
                            }
                            .font(.headline)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // 游戏设置
                Section("游戏设置") {
                    Toggle("声音效果", isOn: .constant(true))
                    Toggle("背景音乐", isOn: .constant(true))
                }
                
                // 关于
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
                
                // 退出登录
                if userVM.isLoggedIn {
                    Section {
                        Button(action: {
                            userVM.logout()
                        }) {
                            Text("退出登录")
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showLoginSheet) {
                LoginView(userVM: userVM)
            }
        }
    }
}
#Preview {
    SettingsView(userVM: UserViewModel())
}
