//
//  TimelineViewModel.swift
//  Echoo
//
//  Created by Kato Daito on 2025/08/05.
//

import Foundation
import Firebase
import FirebaseFirestore

@MainActor
class TimelineViewModel: ObservableObject {
    @Published var latestPosts: [Post] = []
    @Published var popularPosts: [Post] = []
    @Published var forYouPosts: [Post] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    func fetchLatestPosts() async {
        isLoading = true
        
        do {
            let snapshot = try await db.collection("posts")
                .order(by: "createdAt", descending: true)
                .limit(to: 50)
                .getDocuments()
            
            self.latestPosts = try snapshot.documents.compactMap { document in
                try document.data(as: Post.self)
            }
        } catch {
            print("Error fetching latest posts: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchPopularPosts() async {
        isLoading = true
        
        do {
            let snapshot = try await db.collection("posts")
                .order(by: "likeCount", descending: true)
                .limit(to: 50)
                .getDocuments()
            
            self.popularPosts = try snapshot.documents.compactMap { document in
                try document.data(as: Post.self)
            }
        } catch {
            print("Error fetching popular posts: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchForYouPosts(userAge: Int?, userGender: String?) async {
        isLoading = true
        
        do {
            let snapshot = try await db.collection("posts")
                .order(by: "createdAt", descending: true)
                .limit(to: 100)
                .getDocuments()
            
            let allPosts = try snapshot.documents.compactMap { document in
                try document.data(as: Post.self)
            }
            
            // ユーザーの属性に基づいてフィルタリング
            self.forYouPosts = allPosts.filter { post in
                return isPostTargetedForUser(post: post, userAge: userAge, userGender: userGender)
            }
            
        } catch {
            print("Error fetching for you posts: \(error)")
        }
        
        isLoading = false
    }
    
    private func isPostTargetedForUser(post: Post, userAge: Int?, userGender: String?) -> Bool {
        // ターゲット条件が設定されていない場合は全員に表示
        if post.targetMinAge == nil && post.targetMaxAge == nil && post.targetGender == nil {
            return true
        }
        
        // 年齢チェック
        if let userAge = userAge {
            if let minAge = post.targetMinAge, userAge < minAge {
                return false
            }
            if let maxAge = post.targetMaxAge, userAge > maxAge {
                return false
            }
        }
        
        // 性別チェック
        if let userGender = userGender, let targetGender = post.targetGender {
            if targetGender != "all" && userGender != targetGender {
                return false
            }
        }
        
        return true
    }
    
    func refreshAllPosts(userAge: Int?, userGender: String?) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchLatestPosts() }
            group.addTask { await self.fetchPopularPosts() }
            group.addTask { await self.fetchForYouPosts(userAge: userAge, userGender: userGender) }
        }
    }
}