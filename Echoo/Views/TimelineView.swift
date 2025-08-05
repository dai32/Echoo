//
//  TimelineView.swift
//  Echoo
//
//  Created by Kato Daito on 2025/08/05.
//

import SwiftUI
import FirebaseFirestore

struct TimelineView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var timelineViewModel = TimelineViewModel()
    @State private var selectedTab = 0
    @State private var currentUser: User?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // カスタムタブセレクター
                HStack(spacing: 0) {
                    ForEach(0..<3) { index in
                        Button(action: {
                            selectedTab = index
                        }) {
                            Text(tabTitle(for: index))
                                .font(.headline)
                                .foregroundColor(selectedTab == index ? .blue : .secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(.separator)),
                    alignment: .bottom
                )
                
                // タブコンテンツ
                TabView(selection: $selectedTab) {
                    // 新着タブ
                    PostListView(
                        posts: timelineViewModel.latestPosts,
                        isLoading: timelineViewModel.isLoading,
                        emptyMessage: "まだ投稿がありません"
                    )
                    .tag(0)
                    
                    // 人気タブ
                    PostListView(
                        posts: timelineViewModel.popularPosts,
                        isLoading: timelineViewModel.isLoading,
                        emptyMessage: "人気の投稿がありません"
                    )
                    .tag(1)
                    
                    // For Youタブ
                    PostListView(
                        posts: timelineViewModel.forYouPosts,
                        isLoading: timelineViewModel.isLoading,
                        emptyMessage: "あなた向けの投稿がありません"
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Echoo")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await refreshPosts()
            }
        }
        .task {
            await loadInitialData()
        }
        .onChange(of: selectedTab) { _, newValue in
            Task {
                await loadTabData(for: newValue)
            }
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "新着"
        case 1: return "人気"
        case 2: return "For You"
        default: return ""
        }
    }
    
    private func loadInitialData() async {
        await fetchCurrentUser()
        await loadTabData(for: selectedTab)
    }
    
    private func loadTabData(for tabIndex: Int) async {
        switch tabIndex {
        case 0:
            await timelineViewModel.fetchLatestPosts()
        case 1:
            await timelineViewModel.fetchPopularPosts()
        case 2:
            await timelineViewModel.fetchForYouPosts(
                userAge: currentUser?.age,
                userGender: currentUser?.gender
            )
        default:
            break
        }
    }
    
    private func refreshPosts() async {
        await fetchCurrentUser()
        await timelineViewModel.refreshAllPosts(
            userAge: currentUser?.age,
            userGender: currentUser?.gender
        )
    }
    
    private func fetchCurrentUser() async {
        guard let userId = authViewModel.userSession?.uid else { return }
        
        do {
            let document = try await Firestore.firestore()
                .collection("users")
                .document(userId)
                .getDocument()
            
            self.currentUser = try document.data(as: User.self)
        } catch {
            print("Error fetching current user: \(error)")
        }
    }
}

// 投稿リストを表示する再利用可能なビュー
struct PostListView: View {
    let posts: [Post]
    let isLoading: Bool
    let emptyMessage: String
    
    var body: some View {
        Group {
            if isLoading && posts.isEmpty {
                VStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("読み込み中...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    Spacer()
                }
            } else if posts.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "bubble.right")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text(emptyMessage)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    Spacer()
                }
            } else {
                List(posts) { post in
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
}

#Preview {
    TimelineView()
        .environmentObject(AuthViewModel())
}
