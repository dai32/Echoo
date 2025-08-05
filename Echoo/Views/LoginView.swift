//
//  LoginView.swift
//  Echoo
//
//  Created by Kato Daito on 2025/08/05.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                // アプリタイトル
                Text("Echoo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 40)
                
                // メールアドレス入力
                TextField("メールアドレス", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                // パスワード入力
                SecureField("パスワード", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // ログインボタン
                Button(action: {
                    Task {
                        await loginUser()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("ログイン")
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                
                Spacer()
                
                // サインアップへの遷移
                NavigationLink(destination: SignupView().environmentObject(authViewModel)) {
                    Text("アカウントをお持ちでない方はこちら")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 30)
            .navigationBarHidden(true)
        }
        .alert("エラー", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func loginUser() async {
        isLoading = true
        
        do {
            try await authViewModel.login(email: email, password: password)
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
        
        isLoading = false
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}