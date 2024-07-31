//
//  Chat.swift
//  calmSpace
//
//  Created by Mnumzana Franklin Moyo on 7/14/24.
//

import Foundation
import FirebaseFirestoreSwift

struct Chat: Identifiable, Decodable {
    @DocumentID var id: String?
    var title: String
    var content: String
    var userId: String
}
