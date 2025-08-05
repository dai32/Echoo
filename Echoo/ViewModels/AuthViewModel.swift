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
    
    init() {
        self.userSession = Auth.auth().currentUser
    }
    
    func signUp(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
        } catch {
            print("Failed to sign up: \(error.localizedDescription)")
            throw error
        }
    }
    
    func login(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
        } catch {
            print("Failed to login: \(error.localizedDescription)")
            throw error
        }
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
        guard let user = Auth.auth().currentUser else { return }
        
        do {
            // 再認証が必要
            let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: password)
            try await user.reauthenticate(with: credential)
            
            // Firestoreからユーザーデータを削除
            if let userID = user.uid as String? {
                try await Firestore.firestore().collection("users").document(userID).delete()
            }
            
            // アカウントを削除
            try await user.delete()
            self.userSession = nil
        } catch {
            print("Failed to delete account: \(error.localizedDescription)")
            throw error
        }
    }
    
    func uploadUserData(username: String) async throws {
        guard let user = userSession else { return }
        
        let userData = User(
            id: user.uid,
            email: user.email ?? "",
            username: username,
            age: nil,
            gender: nil,
            createdAt: Timestamp()
        )
        
        do {
            try await Firestore.firestore().collection("users").document(user.uid).setData(from: userData)
        } catch {
            print("Failed to upload user data: \(error.localizedDescription)")
            throw error
        }
    }
}