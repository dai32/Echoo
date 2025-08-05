//
//  NewPostView.swift
//  Echoo
//
//  Created by Kato Daito on 2025/08/05.
//

import SwiftUI

struct NewPostView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Image(systemName: "plus.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("新規投稿")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 16)
                
                Text("投稿機能は次のステップで実装します")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                
                Spacer()
            }
            .navigationTitle("新規投稿")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NewPostView()
        .environmentObject(AuthViewModel())
}