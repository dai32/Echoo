//
//  Comment.swift
//  Echoo
//
//  Created by Kato Daito on 2025/08/05.
//

import FirebaseFirestore
import Firebase

struct Comment: Identifiable, Codable {
    @DocumentID var id: String?
    let userID: String
    let username: String
    let text: String
    let createdAt: Timestamp
}
