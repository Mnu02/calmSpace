//
//  ChatDetailView.swift
//  calmSpace
//
//  Created by Mnumzana Franklin Moyo on 7/15/24.
//

import SwiftUI
import OpenAISwift

final class ViewModel: ObservableObject {
    init() {}
    
    private var client: OpenAISwift?
    
    func setup() {
        client = OpenAISwift(config: OpenAISwift.Config.makeDefaultOpenAI(apiKey:"sk-proj-t3OqwcRo9lRvwAZRMf3dT3BlbkFJUDUOMYQcfqgkf9cM1TvI"))
    }
    
    func send(text: String, completion: @escaping (String) -> Void) {
        client?.sendCompletion(with: text, maxTokens: 500, completionHandler: { result in
            switch result {
            case .success (let model):
                let output = model.choices?.first?.text ?? ""
                completion(output)
            case .failure (let error):
                print("Error:\(error.localizedDescription)")
            }
        })
    }
}

struct ChatDetailView: View {
    
    var chat: Chat
    @State private var messages: [Message] = []
    @State private var messageText: String = ""
    @ObservedObject private var messageService = MessageService()
    @ObservedObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            
            Rectangle()
                .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
                .foregroundColor(.deepPurple)
                .padding(1)

            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(messages) { message in
                        HStack {
                            if message.isUser {
                                Spacer()
                                Text(message.text)
                                    .padding()
                                    .background(Color.deepPurple.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                            } else {
                                Text(message.text)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.black)
                                    .cornerRadius(10)
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }
            
            HStack {
                Button(action: startVoiceRecording) {
                    Image(systemName: "mic.fill")
                        .foregroundColor(.white)
                }
                
                TextField("Type a message...", text: $messageText)
                    .padding()
                    .frame(height: 35)
                    .background(.white)
                    .cornerRadius(10)
                    
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(.leading, 5)
                }
            }
            .padding(10)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(Color.deepPurple)
        }
        .navigationTitle(chat.title)
        .onAppear {
            viewModel.setup()
            messageService.fetchMessages { error in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    
    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let userMessage = Message(id: UUID().uuidString, text: messageText, isUser: true, timestamp: Date())
        messages.append(userMessage)
        
        viewModel.send(text: messageText) { response in
                    let botMessage = Message(id: UUID().uuidString, text: response, isUser: false, timestamp: Date())
                    print("GPT ANSWER: " , response)
                    DispatchQueue.main.async {
                        messages.append(botMessage)
                    }
                }
                
                messageText = ""
    }
    
    func startVoiceRecording() {
        // Add voice recording logic here
    }
}

struct ChatDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleChat = Chat(id: "123", title: "My lifestyle", content: "Had a good time yesterday at the park", userId: "Mnumzana")
        NavigationView {
            ChatDetailView(chat: sampleChat)
        }
    }
}
