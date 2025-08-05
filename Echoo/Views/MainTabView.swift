//
//  MainTabView.swift
//  Echoo
//
//  Created by Kato Daito on 2025/08/05.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // タイムライン画面
            TimelineView()
                .environmentObject(authViewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("タイムライン")
                }
                .tag(0)
            
            // 新規投稿画面
            NewPostView(selectedTab: $selectedTab)
                .environmentObject(authViewModel)
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("投稿")
                }
                .tag(1)
            
            // プロフィール画面
            NewProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("プロフィール")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
