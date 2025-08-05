//
//  ProfileSetupView.swift
//  Echoo
//
//  Created by Kato Daito on 2025/08/05.
//

import SwiftUI

struct ProfileSetupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var username = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // タイトル
                VStack(spacing: 10) {
                    Text("プロフィール設定")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("あなたのユーザー名を設定してください")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // ユーザー名入力
                VStack(alignment: .leading, spacing: 8) {
                    Text("ユーザー名")
                        .font(.headline)
                    
                    TextField("ユーザー名を入力", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    
                    Text("※ ユーザー名は必須です")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 保存ボタン
                Button(action: {
                    Task {
                        await saveProfile()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("保存")
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isLoading || username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                Spacer()
            }
            .padding(.horizontal, 30)
            .navigationBarHidden(true)
        }
        .interactiveDismissDisabled() // スワイプでの画面閉じを無効化
        .alert("エラー", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveProfile() async {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty else { return }
        
        isLoading = true
        
        do {
            try await authViewModel.uploadUserData(username: trimmedUsername)
            // プロフィール保存が完了したら、この画面は自動的に閉じられ、
            // ContentViewでMainTabViewが表示される
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
        
        isLoading = false
    }
}

#Preview {
    ProfileSetupView()
        .environmentObject(AuthViewModel())
}