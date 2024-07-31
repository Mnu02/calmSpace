//
//  Message.swift
//  calmSpace
//
//  Created by Mnumzana Franklin Moyo on 7/17/24.
//

import Foundation

struct Message: Identifiable {
    let id: UUID = .init()
    let content: String
    let isUser: Bool
    var timestamp: Date
}
