import Foundation
import Combine
import FirebaseFirestore
import FirebaseCore

class MessageService: ObservableObject {
    private let db = Firestore.firestore()
    private var userID: String
    private var chatID: String

    @Published var messages: [Message] = []
    
    init(userID: String, chatID: String) {
        self.userID = userID
        self.chatID = chatID
    }
    
    // Function to fetch messages
    func fetchMessages(completion: @escaping (Error?) -> Void) {
        db.collection("users").document(userID).collection("chats").document(chatID).collection("messages").order(by: "timestamp").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(error)
            } else {
                var fetchedMessages = [Message]()
                for document in querySnapshot!.documents {
                    let id = document.documentID
                    if let text = document["text"] as? String,
                       let isUser = document["isUser"] as? Bool,
                       let timestamp = (document["timestamp"] as? Timestamp)?.dateValue() {
                        
                        let message = Message(content: text, isUser: isUser, timestamp: timestamp)
                        fetchedMessages.append(message)
                    }
                }
                DispatchQueue.main.async {
                    self.messages = fetchedMessages
                    completion(nil)
                }
            }
        }
    }
    
    // Function to save a message
    func saveMessage(_ message: Message, completion: @escaping (Error?) -> Void) {
        let messageData: [String: Any] = [
            "isUser": message.isUser,
            "content": message.content,
            "timestamp": message.timestamp
        ]
        
        db.collection("users").document(userID).collection("chats").document(chatID).collection("messages").addDocument(data: messageData) { error in
            completion(error)
        }
    }
}
