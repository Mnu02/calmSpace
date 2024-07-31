//
//  ChatDetailView.swift
//  calmSpace
//
//  Created by Mnumzana Franklin Moyo on 7/15/24.
//

import SwiftUI
import OpenAI

class ViewModel: ObservableObject {
    @Published var messages: [Message] = [
        .init(content: "Hello", isUser: true, timestamp: Date()),
        .init(content: "Hi", isUser: false, timestamp: Date())
    ]
    
    @Published var feedBackOn: Bool = false
    var toggleText: String {
        return feedBackOn ? "Feedback On" : "Feedback Off"
    }
    
    
    let openAI = OpenAI(apiToken: "sk-proj-l03IA7n2iVtl8dPfa4soT3BlbkFJObcswFBZJmD99cmYydLU")
    
    func sendNewMessage(content :  String) {
        let userMessage = Message(content: content, isUser: true, timestamp: Date())
        self.messages.append(userMessage)
        if feedBackOn {
            getBotReply()
        }
    }
    
    func getBotReply() {
        let query = ChatQuery(
            messages: self.messages.map({
                .init(role: .user, content: $0.content)!
            }),
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
                    self.messages.append(Message(content: message, isUser: false, timestamp: Date()))
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
}

struct ChatDetailView: View {
    @StateObject var chatController: ViewModel = .init()
    @State var string: String = ""
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
            ForEach(chatController.messages) {
                message in
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
    var body: some View {
        Group {
            if message.isUser {
                HStack {
                    Spacer()
                    Text(message.content)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .clipShape(Capsule())
                }
            } else {
                HStack {
                    Text(message.content)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(Color.white)
                        .clipShape(Capsule())
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    ChatDetailView()
}
