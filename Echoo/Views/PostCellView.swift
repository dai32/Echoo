//
//  PostCellView.swift
//  Echoo
//
//  Created by Kato Daito on 2025/08/05.
//

import SwiftUI
import Firebase

struct PostCellView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー（ユーザー名と投稿日時）
            HStack {
                Text(post.username)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(formatDate(post.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 投稿本文
            Text(post.text)
                .font(.body)
                .multilineTextAlignment(.leading)
            
            // フッター（いいね数とターゲット情報）
            HStack {
                // いいねボタン
                HStack(spacing: 4) {
                    Image(systemName: "heart")
                        .foregroundColor(.red)
                    Text("\(post.likeCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // ターゲット情報（設定されている場合のみ表示）
                if hasTargetInfo {
                    HStack(spacing: 4) {
                        Image(systemName: "target")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(targetInfoText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
    }
    
    private var hasTargetInfo: Bool {
        post.targetMinAge != nil || post.targetMaxAge != nil || post.targetGender != nil
    }
    
    private var targetInfoText: String {
        var components: [String] = []
        
        if let minAge = post.targetMinAge, let maxAge = post.targetMaxAge {
            components.append("\(minAge)-\(maxAge)歳")
        } else if let minAge = post.targetMinAge {
            components.append("\(minAge)歳以上")
        } else if let maxAge = post.targetMaxAge {
            components.append("\(maxAge)歳以下")
        }
        
        if let gender = post.targetGender, gender != "all" {
            let genderText = gender == "male" ? "男性" : "女性"
            components.append(genderText)
        }
        
        return components.joined(separator: ", ")
    }
    
    private func formatDate(_ timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        let calendar = Calendar.current
        let now = Date()
        
        // 今日かどうかを判定
        if calendar.isDate(date, inSameDayAs: now) {
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
        
        // 昨日かどうかを判定
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return "昨日"
        }
        
        // それ以外は日付表示
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

#Preview {
    PostCellView(post: Post(
        userID: "user123",
        username: "サンプルユーザー",
        text: "これはサンプル投稿です。SwiftUIとFirebaseを使ったSNSアプリの開発が進んでいます！",
        likeCount: 42,
        createdAt: Timestamp(),
        targetMinAge: 20,
        targetMaxAge: 30,
        targetGender: "all"
    ))
    .padding()
}
