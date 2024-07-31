//
//  Chat.swift
//  calmSpace
//
//  Created by Mnumzana Franklin Moyo on 7/14/24.
//

import Foundation

struct Chat: Identifiable, Decodable {
    var id: String?
    var title: String
    var content: String
    var userId: String
}
