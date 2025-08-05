//
//  PostDetailView.swift
//  Echoo
//
//  Created by Kato Daito on 2025/08/05.
//

import SwiftUI
import Firebase

struct PostDetailView: View {
    let post: Post
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 投稿詳細（後のステップで実装）
                PostCellView(post: post)
                
                Text("投稿詳細画面")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                
                Text("コメント機能やいいね機能は次のステップで実装します")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
        }
        .navigationTitle("投稿詳細")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        PostDetailView(post: Post(
            userID: "user123",
            username: "サンプルユーザー",
            text: "これはサンプル投稿です。",
            likeCount: 42,
            createdAt: Timestamp(),
            targetMinAge: nil,
            targetMaxAge: nil,
            targetGender: nil
        ))
    }
}
