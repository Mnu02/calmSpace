//
//  ChatDetailView.swift
//  calmSpace
//
//  Created by Mnumzana Franklin Moyo on 7/15/24.
//

import SwiftUI
import OpenAI
import Combine
import FirebaseFirestore

class ViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var feedBackOn: Bool = false
    var toggleText: String {
        return feedBackOn ? "Feedback On" : "Feedback Off"
    }
    
   
    private var messageService: MessageService
    private var cancellables = Set<AnyCancellable>()
    
    init(userID: String, chatID: String) {
        self.messageService = MessageService(userID: userID, chatID: chatID)
        fetchMessages()
    }
    
    func fetchMessages() {
        messageService.fetchMessages { error in
            if let error = error {
                print("Error fetching messages: \(error)")
            } else {
                self.messages = self.messageService.messages
            }
        }
        
        messageService.$messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                self?.messages = messages
            }
            .store(in: &cancellables)
    }
    
    func sendNewMessage(content: String) {
        let userMessage = Message(content: content, isUser: true, timestamp: Date())
        self.messages.append(userMessage)
        saveMessageToFirestore(userMessage)
        
        if feedBackOn {
            getBotReply()
        }
    }
    
    func saveMessageToFirestore(_ message: Message) {
        messageService.saveMessage(message) { error in
            if let error = error {
                print("Error saving message: \(error)")
            }
        }
    }
    
    func getBotReply() {
        let query = ChatQuery(
            messages: self.messages.map {
                .init(role: .user, content: $0.content)!
            },
            model: .gpt3_5Turbo
        )
        
        openAI.chats(query: query) { result in
            switch result {
            case .success(let success):
                guard let choice = success.choices.first else {
                    return
                }
                guard let message = choice.message.content?.string else { return }
                DispatchQueue.main.async {
                    let botMessage = Message(content: message, isUser: false, timestamp: Date())
                    self.messages.append(botMessage)
                    self.saveMessageToFirestore(botMessage)
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
}


struct ChatDetailView: View {
    @StateObject var chatController: ViewModel
    @State var string: String = ""

    init(userID: String, chatID: String) {
        _chatController = StateObject(wrappedValue: ViewModel(userID: userID, chatID: chatID))
    }

    var body: some View {
        VStack {
            HStack {
                Toggle(isOn: $chatController.feedBackOn) {
                    Text(chatController.toggleText)
                        .font(.footnote)
                }
                .toggleStyle(SwitchToggleStyle(tint: .purple))
            }
            .padding()
            
            Divider()
            
            ScrollView {
                ForEach(chatController.messages) { message in
                    MessageView(message: message)
                        .padding(5)
                }
            }
            
            Divider()
            
            HStack {
                TextField("Message...", text: self.$string, axis: .vertical)
                    .padding(5)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(15)
                Button {
                    self.chatController.sendNewMessage(content: string)
                    string = ""
                } label: {
                    Image(systemName: "paperplane")
                }
            }
            .padding()
        }
    }
}

struct MessageView: View {
    var message: Message
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: message.timestamp)
    }
    
    var body: some View {
        Group {
            if message.isUser {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(message.content)
                            .padding(.bottom, 2)
                        Text(formattedTimestamp)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(15)
                }
            } else {
                HStack {
                    VStack(alignment: .leading) {
                        Text(message.content)
                            .padding(.bottom, 2)
                        Text(formattedTimestamp)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.black)
                    .foregroundColor(Color.white)
                    .cornerRadius(15)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
    }
}


#Preview {
    ChatDetailView(userID: "9TfbQqrkL4b18luAm5ET24cK6CF2", chatID: "hello")
}
