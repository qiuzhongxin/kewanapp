import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.top, 50)
                
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                                let userId = appleIDCredential.user
                                var username: String? = nil
                                if let fullName = appleIDCredential.fullName {
                                    username = [fullName.givenName, fullName.familyName]
                                        .compactMap { $0 }
                                        .joined(separator: " ")
                                }
                                userVM.loginWithApple(userId: userId, username: username)
                                dismiss()
                            }
                        case .failure(let error):
                            print("登录失败：\(error.localizedDescription)")
                        }
                    }
                )
                .frame(height: 44)
                .padding(.horizontal)
                
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
