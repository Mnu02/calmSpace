import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ManyChatsView: View {
    
    @EnvironmentObject var authManager: AuthManager  // Using the AuthManager
    @State private var chats: [Chat] = []
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isShowingNewChat: Bool = false
    @State private var newChat: Chat? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Text("Hello")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.deepPurple)
                
                ScrollView {
                    VStack {
                        ForEach(chats) { chat in
                            NavigationLink(value: chat) {
                                HStack {
                                    Text(chat.title)
                                        .padding()
                                    Spacer()
                                }
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    Button(action: {
                        // Log out the user and navigate to the welcome view
                        do {
                            try authManager.signOut()
                        } catch let signOutError as NSError {
                            alertMessage = "Error signing out: \(signOutError.localizedDescription)"
                            showAlert = true
                        }
                    }) {
                        Image("logout")
                            .padding()
                            .foregroundColor(.white)
                    }
                    .padding(.top, 30)
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    Button(action: {
                        // Create a new chat and navigate to the chat detail view
                        createNewChat()
                    }) {
                        Image("add-square")
                            .padding()
                            .foregroundColor(.white)
                    }
                    .padding(.top, 30)
                    .padding(.trailing, 20)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.deepPurple)
                
                .navigationDestination(isPresented: $isShowingNewChat) {
                    if let newChat = newChat {
                        ChatDetailView(userID: authManager.currentUser?.uid ?? "", chatID: newChat.id)
                    }
                }
            }
            .onAppear {
                fetchChats()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .fullScreenCover(isPresented: .constant(!authManager.isLoggedIn)) {
                WelcomeView().navigationBarBackButtonHidden(true)
            }
            .navigationDestination(for: Chat.self) { chat in
                ChatDetailView(userID: chat.userId, chatID: chat.id)
            }
        }
    }

    func fetchChats() {
        guard let userId = authManager.currentUser?.uid else {
            alertMessage = "User not authenticated"
            showAlert = true
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("chats")
            .getDocuments { snapshot, error in
                if let error = error {
                    alertMessage = "Error fetching chats: \(error.localizedDescription)"
                    showAlert = true
                } else {
                    if let snapshot = snapshot {
                        self.chats = snapshot.documents.compactMap { document -> Chat? in
                            try? document.data(as: Chat.self)
                        }
                    }
                }
            }
    }
    
    func createNewChat() {
        guard let userId = authManager.currentUser?.uid else {
            alertMessage = "User not authenticated"
            showAlert = true
            return
        }
        
        let db = Firestore.firestore()
        let newChatRef = db.collection("users").document(userId).collection("chats").document()
        let newChat = Chat(id: newChatRef.documentID, title: "New Chat", content: "", userId: userId)
        
        do {
            try newChatRef.setData(from: newChat) { error in
                if let error = error {
                    alertMessage = "Error creating new chat: \(error.localizedDescription)"
                    showAlert = true
                } else {
                    self.chats.append(newChat)
                    self.newChat = newChat
                    self.isShowingNewChat = true
                }
            }
        } catch let error {
            alertMessage = "Error creating new chat: \(error.localizedDescription)"
            showAlert = true
        }
    }
}


#Preview {
    ManyChatsView()
}
