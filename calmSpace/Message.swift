//
//  Message.swift
//  calmSpace
//
//  Created by Mnumzana Franklin Moyo on 7/17/24.
//

import Foundation

struct Message: Identifiable, Codable {
    let id: String
    let text: String
    let isUser: Bool
    var timestamp: Date
}
