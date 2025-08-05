//
//  AuthViewModel.swift
//  Echoo
//
//  Created by Kato Daito on 2025/08/05.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var isLoading = false
    
    init() {
        // Firebase初期化の完了を待ってから認証状態をチェック
        Task {
            await checkAuthState()
        }
    }
    
    private func checkAuthState() async {
        // メインスレッドで認証状態を安全にチェック
        self.userSession = Auth.auth().currentUser
    }
    
    func signUp(email: String, password: String) async throws {
        isLoading = true
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
        } catch {
            print("Failed to sign up: \(error.localizedDescription)")
            throw error
        }
        isLoading = false
    }
    
    func login(email: String, password: String) async throws {
        isLoading = true
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
        } catch {
            print("Failed to login: \(error.localizedDescription)")
            throw error
        }
        isLoading = false
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
        } catch {
            print("Failed to logout: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }
        
        isLoading = true
        
        do {
            // パスワードで再認証
            let credential = EmailAuthProvider.credential(withEmail: user.email!, password: password)
            try await user.reauthenticate(with: credential)
            
            // Firestoreのユーザーデータを削除
            try await Firestore.firestore()
                .collection("users")
                .document(user.uid)
                .delete()
            
            // アカウントを削除
            try await user.delete()
            
            self.userSession = nil
        } catch {
            print("Failed to delete account: \(error.localizedDescription)")
            throw error
        }
        
        isLoading = false
    }
    
    func uploadUserData(username: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }
        
        isLoading = true
        
        do {
            let userData = User(
                email: user.email!,
                username: username,
                age: nil,
                gender: nil,
                createdAt: Timestamp()
            )
            
            try await Firestore.firestore()
                .collection("users")
                .document(user.uid)
                .setData(from: userData)
        } catch {
            print("Failed to upload user data: \(error.localizedDescription)")
            throw error
        }
        
        isLoading = false
    }
}
