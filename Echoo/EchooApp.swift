//
//  EchooApp.swift
//  Echoo
//
//  Created by Kato Daito on 2025/08/05.
//

import SwiftUI
import Firebase

@main
struct EchooApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
