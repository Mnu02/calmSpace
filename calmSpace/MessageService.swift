//
//  MessageService.swift
//  calmSpace
//
//  Created by Mnumzana Franklin Moyo on 7/17/24.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseCore

class MessageService: ObservableObject {
    // Firestore reference
    private let db = Firestore.firestore()
    @Published var messages: [Message] = []  // Use @Published to trigger updates
    
    // Function to fetch messages
    func fetchMessages(completion: @escaping (Error?) -> Void) {
        db.collection("messages").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(error)
            } else {
                var fetchedMessages = [Message]()
                for document in querySnapshot!.documents {
                    let id = document.documentID
                    if let text = document["text"] as? String,
                       let isUser = document["isUser"] as? Bool,
                       let timestamp = (document["timestamp"] as? Timestamp)?.dateValue() {
                        
                        let message = Message(id: id, text: text, isUser: isUser, timestamp: timestamp)
                        fetchedMessages.append(message)
                    }
                }
                DispatchQueue.main.async {
                    self.messages = fetchedMessages  // Update @Published property
                    completion(nil)
                }
            }
        }
    }
}
