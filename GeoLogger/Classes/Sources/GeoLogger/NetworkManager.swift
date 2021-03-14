//
//  File.swift
//  
//
//  Created by Nishith on 07/03/21.
//

import Foundation

enum NetworkError {
    case noInternet, unknown
}

protocol NetworkManagerType {
    func post(_ url: URL, body: [String: Any], complition: @escaping (_ success: Bool,_ error: NetworkError?) -> Void) throws
}

struct NetworkManager: NetworkManagerType {
    //MARK: - Internal methods
    func post(_ url: URL, body: [String: Any], complition: @escaping (_ success: Bool,_ error: NetworkError?) -> Void) throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        let httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { (responseData, response, error) in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                complition(true, nil)
            } else if let networkError = error {
                let nsError = networkError as NSError
                if nsError.code == NSURLErrorNotConnectedToInternet || nsError.code == NSURLErrorNetworkConnectionLost {
                    complition(false, .noInternet)
                }else {
                    complition(false, .unknown)
                }
            } else {
                complition(false, .unknown)
            }
        }.resume()
    }
}
