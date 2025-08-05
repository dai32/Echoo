//
//  ProfileView.swift
//  Echoo
//
//  Created by Kato Daito on 2025/08/05.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentUser: User?
    @State private var isLoading = true
    @State private var showingDeleteAlert = false
    @State private var deletePassword = ""
    @State private var showingDeletePasswordInput = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if isLoading {
                        ProgressView()
                            .padding(.top, 50)
                    } else if let user = currentUser {
                        // プロフィール情報
                        VStack(spacing: 16) {
                            // アバター（プレースホルダー）
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Text(String(user.username.prefix(1)).uppercased())
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                )
                            
                            // ユーザー名
                            Text(user.username)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            // メールアドレス
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            // 年齢・性別情報
                            if let age = user.age, let gender = user.gender {
                                HStack {
                                    Text("\(age)歳")
                                    Text("・")
                                    Text(gender == "male" ? "男性" : gender == "female" ? "女性" : "その他")
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 20)
                        
                        Spacer(minLength: 40)
                        
                        // 設定項目（プレースホルダー）
                        VStack(spacing: 12) {
                            Text("プロフィール編集機能")
                                .font(.headline)
                            Text("次のステップで実装予定")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        Spacer(minLength: 40)
                        
                        // ログアウトボタン
                        Button(action: {
                            authViewModel.logout()
                        }) {
                            Text("ログアウト")
                                .font(.headline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("プロフィール")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await fetchCurrentUser()
        }
        .alert("アカウント削除", isPresented: $showingDeleteAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("削除", role: .destructive) {
                showingDeletePasswordInput = true
            }
        } message: {
            Text("アカウントを削除しますか？この操作は取り消せません。")
        }
        .alert("パスワードを入力", isPresented: $showingDeletePasswordInput) {
            SecureField("パスワード", text: $deletePassword)
            Button("キャンセル", role: .cancel) {
                deletePassword = ""
            }
            Button("削除", role: .destructive) {
                Task {
                    do {
                        try await authViewModel.deleteAccount(password: deletePassword)
                        deletePassword = ""
                    } catch {
                        print("Error deleting account: \(error)")
                        deletePassword = ""
                    }
                }
            }
        } message: {
            Text("アカウント削除にはパスワードの確認が必要です")
        }
    }
    
    private func fetchCurrentUser() async {
        guard let userId = authViewModel.userSession?.uid else { return }
        
        isLoading = true
        
        do {
            let document = try await Firestore.firestore()
                .collection("users")
                .document(userId)
                .getDocument()
            
            if document.exists {
                self.currentUser = try document.data(as: User.self)
            }
        } catch {
            print("Error fetching current user: \(error)")
        }
        
        isLoading = false
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
