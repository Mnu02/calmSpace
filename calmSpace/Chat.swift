//
//  Chat.swift
//  calmSpace
//
//  Created by Mnumzana Franklin Moyo on 7/14/24.
//

import Foundation

struct Chat: Identifiable, Codable, Hashable {
    var id: String
    var title: String
    var content: String
    var userId: String
    
    // Optionally, you can add an initializer if needed
    init(id: String = UUID().uuidString, title: String, content: String, userId: String) {
        self.id = id
        self.title = title
        self.content = content
        self.userId = userId
    }
}

