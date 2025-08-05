//
//  ContentView.swift
//  Echoo
//
//  Created by Kato Daito on 2025/08/05.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        if authViewModel.userSession != nil {
            MainTabView()
                .environmentObject(authViewModel)
        } else {
            LoginView()
                .environmentObject(authViewModel)
        }
    }
}

#Preview {
    ContentView()
}
