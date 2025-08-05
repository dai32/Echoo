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
            // ホーム画面（仮実装）
            NavigationView {
                VStack {
                    Text("ホーム画面")
                        .font(.largeTitle)
                    
                    Button("ログアウト") {
                        authViewModel.logout()
                    }
                    .foregroundColor(.red)
                }
                .navigationTitle("Echoo")
            }
            .tabItem {
                Image(systemName: "house")
                Text("ホーム")
            }
            
            // プロフィール画面（仮実装）
            NavigationView {
                VStack {
                    Text("プロフィール画面")
                        .font(.largeTitle)
                    
                    if let email = authViewModel.userSession?.email {
                        Text("ログイン中: \(email)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .navigationTitle("プロフィール")
            }
            .tabItem {
                Image(systemName: "person")
                Text("プロフィール")
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}