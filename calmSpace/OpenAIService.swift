//
//  OpenAIService.swift
//  calmSpace
//
//  Created by Mnumzana Franklin Moyo on 7/17/24.
//

import Foundation
import Alamofire

struct OpenAIService: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let text: String
    }
}

func sendMessageToOpenAI(message: String, completion: @escaping (Result<String, Error>) -> Void) {
    let headers: HTTPHeaders = [
        "Authorization": "Bearer YOUR_OPENAI_API_KEY",
        "Content-Type": "application/json"
    ]
    
    let parameters: [String: Any] = [
        "model": "text-davinci-003",
        "prompt": message,
        "max_tokens": 150,
        "temperature": 0.7
    ]
    
    AF.request("https://api.openai.com/v1/completions", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        .responseDecodable(of: OpenAIService.self) { response in
            switch response.result {
            case .success(let openAIResponse):
                let reply = openAIResponse.choices.first?.text
                completion(.success(reply ?? ""))
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
}


