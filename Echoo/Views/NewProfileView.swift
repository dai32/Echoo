import SwiftUI
import Firebase
import FirebaseFirestore

struct NewProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var selectedTab = 0
    @State private var isEditingProfile = false
    @State private var editUsername = ""
    @State private var editAge: Int? = nil
    @State private var editGender: String? = nil
    @State private var showingDeleteAlert = false
    @State private var deletePassword = ""
    @State private var showingDeletePasswordInput = false
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // プロフィール情報タブ
                profileInfoView
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("プロフィール")
                    }
                    .tag(0)
                
                // 自分の投稿タブ
                myPostsView
                    .tabItem {
                        Image(systemName: "doc.text")
                        Text("投稿履歴")
                    }
                    .tag(1)
            }
            .navigationTitle("プロフィール")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            profileViewModel.setAuthViewModel(authViewModel)
            await profileViewModel.fetchUserData()
            await profileViewModel.fetchMyPosts()
        }
        .alert("エラー", isPresented: $profileViewModel.showingAlert) {
            Button("OK") { }
        } message: {
            Text(profileViewModel.errorMessage)
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
    
    private var profileInfoView: some View {
        ScrollView {
            VStack(spacing: 24) {
                if profileViewModel.isLoading {
                    ProgressView()
                        .padding(.top, 50)
                } else if let user = profileViewModel.user {
                    // プロフィール情報表示
                    profileHeaderView(user: user)
                    
                    if isEditingProfile {
                        // 編集モード
                        profileEditView
                    } else {
                        // 表示モード
                        profileDisplayView(user: user)
                    }
                    
                    Spacer(minLength: 40)
                    
                    // アクションボタン
                    actionButtonsView
                } else {
                    Text("ユーザー情報を読み込めませんでした")
                        .foregroundColor(.secondary)
                        .padding(.top, 50)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func profileHeaderView(user: User) -> some View {
        VStack(spacing: 16) {
            // アバター
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 100, height: 100)
                .overlay(
                    Text(String(user.username.prefix(1)).uppercased())
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                )
            
            // メールアドレス
            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private func profileDisplayView(user: User) -> some View {
        VStack(spacing: 16) {
            // ユーザー名
            ProfileInfoRow(title: "ユーザー名", value: user.username)
            
            // 年齢
            if let age = user.age {
                ProfileInfoRow(title: "年齢", value: "\(age)歳")
            }
            
            // 性別
            if let gender = user.gender {
                let genderText = gender == "male" ? "男性" : gender == "female" ? "女性" : "その他"
                ProfileInfoRow(title: "性別", value: genderText)
            }
            
            // 編集ボタン
            Button("編集") {
                startEditing(user: user)
            }
            .font(.headline)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var profileEditView: some View {
        VStack(spacing: 16) {
            // ユーザー名編集
            VStack(alignment: .leading, spacing: 8) {
                Text("ユーザー名")
                    .font(.headline)
                TextField("ユーザー名", text: $editUsername)
                    .textFieldStyle(.roundedBorder)
            }
            
            // 年齢編集
            VStack(alignment: .leading, spacing: 8) {
                Text("年齢")
                    .font(.headline)
                Picker("年齢", selection: $editAge) {
                    Text("指定なし").tag(nil as Int?)
                    ForEach(profileViewModel.ageOptions, id: \.self) { age in
                        Text("\(age)歳").tag(age as Int?)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 120)
            }
            
            // 性別編集
            VStack(alignment: .leading, spacing: 8) {
                Text("性別")
                    .font(.headline)
                Picker("性別", selection: $editGender) {
                    Text("指定なし").tag(nil as String?)
                    ForEach(profileViewModel.genderOptions, id: \.0) { option in
                        Text(option.1).tag(option.0 as String?)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // 編集完了ボタン
            HStack(spacing: 12) {
                Button("キャンセル") {
                    isEditingProfile = false
                }
                .font(.headline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Button("完了") {
                    Task {
                        await profileViewModel.updateProfile(
                            username: editUsername,
                            age: editAge,
                            gender: editGender
                        )
                        isEditingProfile = false
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(editUsername.isEmpty ? Color.gray : Color.blue)
                .cornerRadius(12)
                .disabled(editUsername.isEmpty)
            }
        }
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 16) {
            // ログアウトボタン
            Button("ログアウト") {
                authViewModel.logout()
            }
            .font(.headline)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // アカウント削除ボタン
            Button("アカウントを削除") {
                showingDeleteAlert = true
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.red)
            .cornerRadius(12)
        }
    }
    
    private var myPostsView: some View {
        VStack {
            if profileViewModel.isLoading {
                ProgressView()
                    .padding(.top, 50)
            } else if profileViewModel.myPosts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text("投稿がありません")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("最初の投稿を作成してみましょう")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 100)
            } else {
                List(profileViewModel.myPosts) { post in
                    NavigationLink(destination: PostDetailView(post: post)) {
                        PostCellView(post: post)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                }
                .listStyle(.plain)
            }
        }
    }
    
    private func startEditing(user: User) {
        editUsername = user.username
        editAge = user.age
        editGender = user.gender
        isEditingProfile = true
    }
}

// プロフィール情報表示用のヘルパービュー
struct ProfileInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NewProfileView()
        .environmentObject(AuthViewModel())
}
