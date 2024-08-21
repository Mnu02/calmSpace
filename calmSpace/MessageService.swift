import Foundation
import Combine
import FirebaseFirestore
import FirebaseCore

class MessageService: ObservableObject {
    // Firestore reference
    private let db = Firestore.firestore()
    @Published var messages: [Message] = []  // Use @Published to trigger updates
    private var userId: String
    private var chatId: String

    init(userId: String, chatId: String) {
        self.userId = userId
        self.chatId = chatId
        fetchMessages { _ in }
    }

    // Function to fetch messages
    func fetchMessages(completion: @escaping (Error?) -> Void) {
        print("Fetching Messages...")
        db.collection("users").document(userId).collection("chats").document(chatId).collection("messages").order(by: "timestamp").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching messages: \(error.localizedDescription)")
                completion(error)
            } else {
                var fetchedMessages = [Message]()
                for document in querySnapshot!.documents {
                    //let id = document.documentID
                    if let text = document["content"] as? String,
                       let isUser = document["isUser"] as? Bool,
                       let timestamp = (document["timestamp"] as? Timestamp)?.dateValue() {
                        
                        let message = Message(content: text, isUser: isUser, timestamp: timestamp)
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

    // Function to save messages
    func saveMessage(message: Message, completion: @escaping (Error?) -> Void) {
        let documentData: [String: Any] = [
            "content": message.content,
            "isUser": message.isUser,
            "timestamp": message.timestamp
        ]
        
        db.collection("users").document(userId).collection("chats").document(chatId).collection("messages").addDocument(data: documentData) { error in
            completion(error)
        }
    }
}
