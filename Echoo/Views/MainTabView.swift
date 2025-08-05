//
//  MainTabView.swift
//  Echoo
//
//  Created by Kato Daito on 2025/08/05.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            // タイムライン画面
            TimelineView()
                .environmentObject(authViewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("タイムライン")
                }
            
            // 新規投稿画面
            NewPostView()
                .environmentObject(authViewModel)
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("投稿")
                }
            
            // プロフィール画面
            ProfileView()
                .environmentObject(authViewModel)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("プロフィール")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
