//
//  Post.swift
//  Echoo
//
//  Created by Kato Daito on 2025/08/05.
//

import FirebaseFirestoreSwift
import Firebase

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    let userID: String
    let username: String
    let text: String
    var likeCount: Int = 0
    let createdAt: Timestamp
    var targetMinAge: Int?
    var targetMaxAge: Int?
    var targetGender: String?
}