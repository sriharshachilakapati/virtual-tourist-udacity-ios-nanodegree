//
//  ApiDefinition.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 14/04/21.
//

import Foundation

/// A request type to use when you don't want to send any parameters in the API call. This applies only to Query
/// parameters for `GET` and `DELETE` requests and to HTTP Payload attached to `POST` requests.
typealias NilRequest = [String:String]

/// A response type that wraps the binary data. To be used if you are downloading a file for example.
struct BinaryResponse: Codable {
    let data: Data
}

/// A definition for an API. This allows to define the API in a declarative manner and then use those declarations to
/// make the calls. Supports multiple HTTP methods and also auto-mapping of requests to either query parameters or HTTP
/// body depending on the method to be used.
struct ApiDefinition<RequestType: Encodable, ResponseType: Decodable> {
    typealias ApiCompletionHandler = (Result<ResponseType, Error>) -> Void
    
    let url: String
    let method: HttpMethod
    let getDecodableResponseRange: (Data) -> Range<Int> = { data in 0 ..< data.count }
    let headers: () -> [String : String]? = { [:] }
    
    /// Calls the API endpoint with a `payload` and returns the response in a `completion` handler.
    /// - Parameters:
    ///   - payload: The payload to be sent to the API.
    ///   - completion: The completion handler which will be invoked with the API result.
    func call(withPayload payload: RequestType, completion: @escaping ApiCompletionHandler) {
        performCall(withPayload: payload, andPathParameters: [:], completion: completion)
    }
    
    /// Calls the API endpoint with some `pathParameters` and returns the response in a `completion` handler. This uses
    /// an `Encodable` for the parameters and any `{varName}` in the URL will be replaced with the value of
    /// `parameters.varName` in the URL.
    /// - Parameters:
    ///   - parameters: An `Encodable` struct which contains values to be replaced with.
    ///   - completion: The completion handler which will be invoked with the API result.
    func call<T: Encodable>(withPathParameters parameters: T, completion: @escaping ApiCompletionHandler) {
        guard let encodedPayload = try? JSONEncoder().encode(parameters) else { return }
        
        let paramsJson = (try? JSONSerialization.jsonObject(with: encodedPayload, options: []) as? [String: Any] ?? [:])!
        let pathParams = paramsJson.mapValues { value in "\(value)" }
        
        performCall(withPayload: nil, andPathParameters: pathParams, completion: completion)
    }
    
    /// Calls the API endpoint with some `payload`, `pathParameters` and returns the response in a `completion` handler.
    /// - Parameters:
    ///   - payload: The payload that needs to be sent across the network.
    ///   - pathParameters: The parameters which needs to be replaced in URL to make it a valid URL.
    ///   - completion: The completion handler which will be invoked with the API result.
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

/// The method to be used to make a HTTP request.
enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}
