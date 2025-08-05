//
//  SignupView.swift
//  Echoo
//
//  Created by Kato Daito on 2025/08/05.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showProfileSetup = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // アプリタイトル
            Text("新規登録")
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
            
            // パスワード確認入力
            SecureField("パスワード確認", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // サインアップボタン
            Button(action: {
                Task {
                    await signUpUser()
                }
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("新規登録")
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(isLoading || !isValidForm)
            
            Spacer()
        }
        .padding(.horizontal, 30)
        .navigationTitle("新規登録")
        .navigationBarTitleDisplayMode(.inline)
        .alert("エラー", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .fullScreenCover(isPresented: $showProfileSetup) {
            ProfileSetupView()
                .environmentObject(authViewModel)
        }
    }
    
    private var isValidForm: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        !confirmPassword.isEmpty && 
        password == confirmPassword &&
        password.count >= 6
    }
    
    private func signUpUser() async {
        isLoading = true
        
        do {
            try await authViewModel.signUp(email: email, password: password)
            showProfileSetup = true
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
        
        isLoading = false
    }
}

#Preview {
    SignupView()
        .environmentObject(AuthViewModel())
}