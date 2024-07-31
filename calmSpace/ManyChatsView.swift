import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ManyChatsView: View {
    
    @State private var chats: [Chat] = []
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isLoggedOut: Bool = false
    @State private var isShowingNewChat: Bool = false
    @State private var newChat: Chat? = nil
    
    private var sampleChat = Chat(id: "123", title: "My lifestyle", content: "Had a good time yesterday at the park", userId: "Mnumzana")
    
    var body: some View {
        NavigationView {
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
                            NavigationLink(destination: ChatDetailView(chat: chat)) {
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
                            try Auth.auth().signOut()
                            isLoggedOut = true
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
                        let newChat = Chat(id: UUID().uuidString, title: "New Chat", content: "", userId: Auth.auth().currentUser?.uid ?? "")
                        chats.append(newChat)
                        self.newChat = newChat
                        isShowingNewChat = true
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
                
                NavigationLink(destination: ChatDetailView(chat: newChat ?? sampleChat), isActive: $isShowingNewChat) {
                    EmptyView()
                }
            }
            .onAppear {
                fetchChats()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .fullScreenCover(isPresented: $isLoggedOut) {
                WelcomeView().navigationBarBackButtonHidden(true)
            }
        }
    }

    func fetchChats() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            alertMessage = "User not authenticated"
            showAlert = true
            return
        }
        
        db.collection("chats")
            .whereField("userId", isEqualTo: userId)
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
}

#Preview {
    ManyChatsView()
}
