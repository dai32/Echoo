import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

@MainActor
class NewPostViewModel: ObservableObject {
    @Published var text = ""
    @Published var targetMinAge: Int? = nil
    @Published var targetMaxAge: Int? = nil
    @Published var targetGender: String? = "all"
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showingAlert = false
    
    // 年齢選択用の配列
    let ageOptions = Array(18...80)
    let genderOptions = [
        ("all", "すべて"),
        ("male", "男性"),
        ("female", "女性")
    ]
    
    func uploadPost() async -> Bool {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "投稿内容を入力してください"
            showingAlert = true
            return false
        }
        
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "ログインが必要です"
            showingAlert = true
            return false
        }
        
        isLoading = true
        
        do {
            // ユーザー情報を取得
            let userDocument = try await Firestore.firestore()
                .collection("users")
                .document(currentUser.uid)
                .getDocument()
            
            guard let userData = try? userDocument.data(as: User.self) else {
                errorMessage = "ユーザー情報の取得に失敗しました"
                showingAlert = true
                isLoading = false
                return false
            }
            
            // 新しい投稿を作成
            let newPost = Post(
                userID: currentUser.uid,
                username: userData.username,
                text: text.trimmingCharacters(in: .whitespacesAndNewlines),
                likeCount: 0,
                createdAt: Timestamp(),
                targetMinAge: targetMinAge,
                targetMaxAge: targetMaxAge,
                targetGender: targetGender == "all" ? nil : targetGender
            )
            
            // Firestoreに保存
            try await Firestore.firestore()
                .collection("posts")
                .addDocument(from: newPost)
            
            // 投稿成功後、フォームをリセット
            await MainActor.run {
                text = ""
                targetMinAge = nil
                targetMaxAge = nil
                targetGender = "all"
                isLoading = false
            }
            
            return true
            
        } catch {
            print("Error uploading post: \(error)")
            errorMessage = "投稿の送信に失敗しました"
            showingAlert = true
            isLoading = false
            return false
        }
    }
    
    func resetForm() {
        text = ""
        targetMinAge = nil
        targetMaxAge = nil
        targetGender = "all"
    }
    
    var isFormValid: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
