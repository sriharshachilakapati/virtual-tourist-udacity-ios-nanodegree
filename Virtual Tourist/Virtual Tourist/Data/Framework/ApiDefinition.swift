//
//  ApiDefinition.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 14/04/21.
//

import Foundation

typealias NilRequest = [String:String]

struct BinaryResponse: Codable {
    let data: Data
}

struct ApiDefinition<RequestType: Encodable, ResponseType: Decodable> {
    typealias ApiCompletionHandler = (Result<ResponseType, Error>) -> Void
    
    let url: String
    let method: HttpMethod
    let getDecodableResponseRange: (Data) -> Range<Int> = { data in 0 ..< data.count }
    let headers: () -> [String : String]? = { [:] }
    
    func call(withPayload payload: RequestType, completion: @escaping ApiCompletionHandler) {
        performCall(withPayload: payload, andPathParameters: [:], completion: completion)
    }
    
    func call(withPathParameters parameters: [String : String], completion: @escaping ApiCompletionHandler) {
        performCall(withPayload: nil, andPathParameters: parameters, completion: completion)
    }
    
    func call<T: Encodable>(withPathParameters parameters: T, completion: @escaping ApiCompletionHandler) {
        guard let encodedPayload = try? JSONEncoder().encode(parameters) else { return }
        
        let paramsJson = (try? JSONSerialization.jsonObject(with: encodedPayload, options: []) as? [String: Any] ?? [:])!
        let pathParams = paramsJson.mapValues { value in "\(value)" }
        
        performCall(withPayload: nil, andPathParameters: pathParams, completion: completion)
    }
    
    func call(completion: @escaping ApiCompletionHandler) {
        performCall(withPayload: nil, andPathParameters: [:], completion: completion)
    }
    
    private func performCall(withPayload payload: RequestType?, andPathParameters pathParameters: [String : String], completion: @escaping ApiCompletionHandler) {
        var urlString = self.url
        
        for pathParameter in pathParameters {
            urlString = urlString.replacingOccurrences(of: "{\(pathParameter.key)}", with: pathParameter.value)
        }
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 500)
        
        request.httpMethod = method.rawValue
        
        // Set the headers
        if let headers = headers() {
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        // Handle the payload
        if let payload = payload {
            do {
                let encodedPayload = try JSONEncoder().encode(payload)
                
                switch method {
                    case .get, .delete:
                        // GET and DELETE uses Query parameters
                        let queryParams = (try? JSONSerialization.jsonObject(with: encodedPayload, options: []) as? [String: Any] ?? [:])!
                        request.setQueryParameters(queryParams)
                        
                    case .post:
                        // POST takes it as a body
                        request.httpBody = encodedPayload
                }
            } catch {
                completion(Result.failure(error))
                return
            }
        }
        
        // Create a network request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(Result.failure(error!))
                return
            }
            
            do {
                if ResponseType.self == BinaryResponse.self {
                    completion(Result.success(BinaryResponse(data: data) as! ResponseType))
                    return
                }
                
                let decoder = JSONDecoder()
                let subsetRange = getDecodableResponseRange(data)
                let newData = data.subdata(in: subsetRange)
                let value = try decoder.decode(ResponseType.self, from: newData)
                completion(Result.success(value))
            } catch {
                completion(Result.failure(error))
            }
        }
        
        // Fire the network call
        task.resume()
    }
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}
