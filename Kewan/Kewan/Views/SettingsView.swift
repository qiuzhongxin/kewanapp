import SwiftUI

// 创建一个颜色选择的存储类
class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @AppStorage("backgroundColor") var backgroundColor: String = "purple"
    @AppStorage("backgroundOpacity") var backgroundOpacity: Double = 0.5
    
    // 获取实际的 Color 对象
    var color: Color {
        switch backgroundColor {
        case "green": return .green
        case "blue": return .blue
        case "yellow": return .yellow
        case "purple": return .purple
        case "red": return .red
        case "black": return .black
        case "white": return .white
        case "orange": return .orange
        case "mint": return.mint
        case "pink": return.pink
        default: return .purple
        }
    }
}

struct SettingsView: View {
    @ObservedObject var userVM: UserViewModel
    @StateObject private var settings = AppSettings.shared
    @State private var showLoginSheet = false
    
    private let colorOptions = [
        ("紫色", "purple"),
        ("绿色", "green"),
        ("蓝色", "blue"),
        ("黄色", "yellow"),
        ("红色", "red"),
        ("黑色", "black"),
        ("白色", "white"),
        ("橙色", "orange"),
        ("青色", "mint"),
        ("粉色", "pink")
    ]
    
    var body: some View {
        Form {
            // 用户信息区域
            Section {
                HStack {
                    Image(systemName: userVM.userAvatar)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                        .padding(.vertical, 10)
                    
                    if userVM.isLoggedIn {
                        VStack(alignment: .leading) {
                            Text(userVM.username)
                                .font(.title3)
                                .bold()
                            Text("已登录")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    } else {
                        Button("点击登录") {
                            showLoginSheet = true
                        }
                        .font(.title3)
                    }
                }
            }
            
            // 背景颜色设置
            Section(header: Text("背景颜色")) {
                ForEach(colorOptions, id: \.1) { option in
                    HStack {
                        Circle()
                            .fill(getColor(option.1))
                            .frame(width: 20, height: 20)
                        Text(option.0)
                        Spacer()
                        if settings.backgroundColor == option.1 {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        settings.backgroundColor = option.1
                    }
                }
                
                
            }
            
            // 添加透明度滑块
            VStack(alignment: .leading, spacing: 8) {
                Text("背景透明度")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                HStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.gray)
                        .opacity(0.2)
                    Slider(value: $settings.backgroundOpacity, in: 0.1...1.0)
                        .tint(.gray)
                        .frame(height: 30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray)
                                .frame(height: 4)
                                .opacity(0.1)
                        )
                    Image(systemName: "circle.fill")
                        .foregroundColor(.gray)
                }
                // 预览区域
                Section(header: Text("")) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(settings.color.opacity(settings.backgroundOpacity))
                        .frame(height: 100)
                }
            }
//            .padding(.top, 8)
            
            
            
            // 设置选项
//            Section("通用设置") {
//                Toggle("声音效果", isOn: .constant(true))
//                Toggle("背景音乐", isOn: .constant(true))
//            }
            
            // 其他信息
            Section("关于") {
                HStack {
                    Text("版本")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.gray)
                }
                
                NavigationLink("隐私政策") {
                    Text("隐私政策内容")
                }
                
                NavigationLink("用户协议") {
                    Text("用户协议内容")
                }
            }
            
            // 登出按钮
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
    
    private func getColor(_ name: String) -> Color {
        switch name {
        case "green": return .green
        case "blue": return .blue
        case "yellow": return .yellow
        case "purple": return .purple
        case "red": return .red
        case "black": return .black
        case "white": return .white
        case "orange": return .orange
        case "mint": return.mint
        case "pink": return.pink
        default: return .purple
        }
    }
}

// 添加预览
#Preview {
    NavigationView {
        SettingsView(userVM: UserViewModel())
    }
}
