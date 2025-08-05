import SwiftUI
import Firebase
import FirebaseFirestore

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var myPosts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showingAlert = false
    
    private var authViewModel: AuthViewModel?
    
    init() {
        // デフォルトの初期化（AuthViewModelは後で設定）
    }
    
    func setAuthViewModel(_ authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }
    
    func fetchUserData() async {
        guard let userId = getCurrentUserId() else { return }
        
        isLoading = true
        
        do {
            let document = try await Firestore.firestore()
                .collection("users")
                .document(userId)
                .getDocument()
            
            if document.exists {
                self.user = try document.data(as: User.self)
            }
        } catch {
            print("Error fetching user data: \(error)")
            errorMessage = "ユーザー情報の取得に失敗しました"
            showingAlert = true
        }
        
        isLoading = false
    }
    
    func fetchMyPosts() async {
        guard let userId = getCurrentUserId() else { return }
        
        isLoading = true
        
        do {
            let snapshot = try await Firestore.firestore()
                .collection("posts")
                .whereField("userID", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            self.myPosts = snapshot.documents.compactMap { document in
                try? document.data(as: Post.self)
            }
        } catch {
            print("Error fetching my posts: \(error)")
            errorMessage = "投稿の取得に失敗しました"
            showingAlert = true
        }
        
        isLoading = false
    }
    
    func updateProfile(username: String, age: Int?, gender: String?) async {
        guard let userId = getCurrentUserId() else { return }
        
        isLoading = true
        
        do {
            let updateData: [String: Any] = [
                "username": username,
                "age": age as Any,
                "gender": gender as Any
            ]
            
            try await Firestore.firestore()
                .collection("users")
                .document(userId)
                .updateData(updateData)
            
            // ローカルのユーザー情報も更新
            if var currentUser = user {
                currentUser.username = username
                currentUser.age = age
                currentUser.gender = gender
                self.user = currentUser
            }
            
        } catch {
            print("Error updating profile: \(error)")
            errorMessage = "プロフィールの更新に失敗しました"
            showingAlert = true
        }
        
        isLoading = false
    }
    
    private func getCurrentUserId() -> String? {
        // AuthViewModelがFirebase無効化されているため、仮の実装
        // 実際のFirebase環境では Auth.auth().currentUser?.uid を使用
        return "dummy_user_id"
    }
    
    // 年齢選択用の配列
    let ageOptions = Array(18...80)
    let genderOptions = [
        ("male", "男性"),
        ("female", "女性"),
        ("other", "その他")
    ]
}
