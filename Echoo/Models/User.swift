//
//  User.swift
//  Echoo
//
//  Created by Kato Daito on 2025/08/05.
//

import FirebaseFirestore
import Firebase

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let email: String
    var username: String
    var age: Int?
    var gender: String?
    let createdAt: Timestamp
}
