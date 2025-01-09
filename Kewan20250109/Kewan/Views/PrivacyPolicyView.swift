import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("隐私政策")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 4)
                
                Text("感谢您使用 泡泡英语。我们非常重视您的隐私保护，特此说明我们的数据处理方式。")
                    .padding(.bottom)
                
                Group {
                    privacySection(title: "一、数据收集",
                                 content: "• 本应用不收集任何用户个人信息\n• 不使用后台服务器\n• 仅使用 Apple iCloud 进行身份验证")
                    
                    privacySection(title: "二、iCloud 登录",
                                 content: "• 使用 Apple 官方的 iCloud 登录服务\n• 登录过程完全由 Apple 负责处理\n• 我们无法获取您的 Apple ID 密码")
                    
                    privacySection(title: "三、数据存储",
                                 content: "• 所有数据仅存储在您的设备本地\n• 如果您启用 iCloud，数据将同步到您的 iCloud 账户\n• 我们无法访问您的个人数据")
                    
                    privacySection(title: "四、安全保障",
                                 content: "• 不收集用户使用数据\n• 不追踪用户行为\n• 不与第三方共享任何信息\n• 无后台服务器，无数据泄露风险")
                    
                    privacySection(title: "五、权限说明",
                                 content: "本应用可能需要以下权限：\n• iCloud 登录权限：用于账号验证")
                    
                    privacySection(title: "六、联系我们",
                                 content: "如对隐私政策有任何疑问，请联系：397260568@.qq.com")
                }
                
                Text("最后更新日期：2024年12月")
                    .foregroundColor(.gray)
                    .padding(.top)
            }
            .padding()
        }
    }
    
    private func privacySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .bold()
            Text(content)
                .font(.body)
        }
    }
}

#Preview {
    PrivacyPolicyView()
} 
