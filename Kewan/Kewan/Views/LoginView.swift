import SwiftUI

struct LoginView: View {
    @ObservedObject var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss
    @State private var username = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.top, 50)
                
                TextField("请输入用户名", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    userVM.login(username: username)
                    dismiss()
                }) {
                    Text("登录")
                        .foregroundColor(.white)
                        .frame(width: 200, height: 44)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .disabled(username.isEmpty)
                
                Spacer()
            }
            .navigationTitle("登录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}
#Preview {
    LoginView(userVM: UserViewModel())
}
